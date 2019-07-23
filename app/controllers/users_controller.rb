require 'net/http'
require 'uri'
require 'json'
require 'base64'

class UsersController < ApplicationController

  def index
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(dest: params[:dest], subject: params[:subject], body: params[:body], attachments: params[:attachments])

    if @user.save
      attachments = user_params[:attachments] # 添付ファイルの情報を代入
      post = {} # ファイルの名前と種類を取得する
      if params[:attachments]
        post[:attachments] = attachments.read # ファイルを読み込んでアップロード
        post[:attachments_type] = attachments.content_type # xlsxファイルを読み込んでアップロード
        post[:attachments_name] = attachments.original_filename # ファイル名を読み込んでアップロード
        encode = Base64.strict_encode64(post[:attachments])  # ファイルをエンコード化。「Base64.encode64」にすると改行の「\n」が認識されエラーになる
      end
      # dataにまとめる（あとでreq.bodyするため。課題のexample valueに合わした形式）
      data = {
        "dest": @user.dest,
        "subject": @user.subject,
        "body": @user.body,
        "attachments":
        # "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,UEsDBBQABgAIAAAAIQBBN4LPbgEAAAQFAAATAAgCW0NvbnRlbnRfVHlwZXNdLnhtbCCiBAIo .... "
         [
           [ post[:attachments_name],   # 課題のexmaple valueのように"経歴書AK.xlsx" と表示されるように
             "data:#{post[:attachments_type]};base64, #{encode}"  # 上のコメントの例に表示形式を合わす。ファイルの内容によって「data:」以降のコードが変わる。「;base64,」以降のコードはエンコードされた内容
           ]
         ]
      }.to_json #全部まとめてjsonに変換

# リクエストヘッダにAPIを設定 参照URL: https://teratail.com/questions/131863
      uri = URI.parse('https://hlw9zpstkf.execute-api.ap-northeast-1.amazonaws.com/production/submit')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.request_uri)
      req["X-API-KEY"] = 'wFRndCxe2ido3kcCvUQa8OFw0W5wfEf7UJRZ1Rfb'
      req.body = data #データをまとめて取得
      res = http.request(req)
      render "index" # 送信ボタン押したら受付完了画面へ
    end
  end

  private

    def user_params # strongパラメーター（ネストしてない版）
      params.permit(:dest, :subject, :body, :attachments)
    end
end
