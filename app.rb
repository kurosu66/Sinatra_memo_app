# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
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
  conn.exec("INSERT INTO memos (title,content) VALUES ('#{params[:title]}','#{params[:content]}')")
  redirect '/memos'
end

get '/memos/:id' do
  @memo_id = params[:id]
  conn.exec("SELECT * FROM memos where id = #{params[:id]}") do |result|
    result.each do |row|
      @memo_title = row["title"]
      @memo_content = row["content"]
    end
  end

  erb :detail
end

get '/memos/:id/edit' do
  @memo_id = params[:id]
  conn.exec("SELECT * FROM memos where id = #{params[:id]}") do |result|
    result.each do |row|
      @memo_title = row["title"]
      @memo_content = row["content"]
    end
  end

  erb :edit
end

patch '/memos/:id' do
  conn.exec("UPDATE memos SET title = '#{params[:title]}', content = '#{params[:content]}' WHERE id = #{params[:id]}")
  redirect '/memos'
end

delete '/memos/:id' do
  conn.exec("delete from memos WHERE id = #{params[:id]}")
  redirect '/memos'
end
