# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

helpers do
  def sanitize(text)
    Rack::Utils.escape_html(text)
  end
end

memos = File.open('memos.json') do |memo|
  JSON.parse(memo.read)
end

get '/memos' do
  @memos = memos
  erb :memos
end

get '/new' do
  erb :new
end

post '/memos' do
  next_memo_id = SecureRandom.uuid
  memos[next_memo_id] = { 'title' => params[:title], 'content' => params[:content] }

  File.open('memos.json', 'w') do |file|
    JSON.dump(memos, file)
  end

  redirect '/memos'
end

get '/memos/:id' do
  @memo_id = params[:id]
  if memos[@memo_id]
    @memo_title = memos[@memo_id]['title']
    @memo_content = memos[@memo_id]['content']
  end

  erb :detail
end

get '/memos/:id/edit' do
  @memo_id = params[:id]
  if memos[@memo_id]
    @memo_title = memos[@memo_id]['title']
    @memo_content = memos[@memo_id]['content']
  end

  erb :edit
end

patch '/memos/:id' do
  @memo_id = params[:id]
  File.open('memos.json', 'w') do |file|
    if memos[@memo_id]
      memos[@memo_id]['title'] = params[:title]
      memos[@memo_id]['content'] = params[:content]
    end
    JSON.dump(memos, file)
  end

  redirect '/memos'
end

delete '/memos/:id' do
  @memo_id = params[:id]
  memos.delete(@memo_id)

  File.open('memos.json', 'w') do |file|
    JSON.dump(memos, file)
  end

  redirect '/memos'
end
