# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

helpers do
  def sanitize(text)
    Rack::Utils.escape_html(text)
  end
end

conn = PG.connect( dbname: 'memo_app' )

get '/memos' do
  @conn = conn
  erb :memos
end

get '/new' do
  erb :new
end

post '/memos' do
  conn.exec_params(
    %q{INSERT INTO memos (title, content) VALUES ($1, $2)},
    ["#{params[:title]}", "#{params[:content]}"]
  )
  redirect '/memos'
end

get '/memos/:id' do
  @memo_id = params[:id]
  sql = %q{SELECT * FROM memos WHERE id = ($1)}
  conn.exec_params(sql,[params[:id]]) do |result|
    result.each do |row|
      @memo_title = row["title"]
      @memo_content = row["content"]
    end 
  end
  erb :detail
end

get '/memos/:id/edit' do
  @memo_id = params[:id]
  sql = %q{SELECT * FROM memos WHERE id = ($1)}
  conn.exec_params(sql,[params[:id]]) do |result|
    result.each do |row|
      @memo_title = row["title"]
      @memo_content = row["content"]
    end 
  end

  erb :edit
end

patch '/memos/:id' do
  sql = %q{UPDATE memos SET title = ($1), content = ($2) WHERE id = ($3)}
  conn.exec_params(sql,[params[:title], params[:content], params[:id]])
  redirect '/memos'
end

delete '/memos/:id' do
  sql = %q{delete from memos WHERE id = ($1)}
  conn.exec_params(sql, [params[:id]])
  redirect '/memos'
end
