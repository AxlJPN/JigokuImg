require 'nokogiri'
require 'open-uri'

class Misawa < ActiveRecord::Base
    @@url = 'http://jigokuno.com/'
    @@maxEid = 0
    
    # トップページを見て、最大の記事番号を取得する
    def getMaxEid
      # すでにmaxEidが存在する場合、それを返す
      if @@maxEid != 0
        return @@maxEid
      end
    
      # EUC-JPで開き、UTF-8に変換する
      html = Nokogiri::HTML(open(@@url, 'r:euc-jp').read.encode('utf-8'))
    
      # Aタグをパース
      parses = html.css('a')
    
      eid = 0
    
      parses.each{ |parse|
        # href要素を持つもののみ探す
        href = parse[:href]
        unless href
          next
        end
    
        # eidを持つもののみを探す
        pos = href.index('eid=')
        unless pos
          next
        end
    
        # 'eid='以降の数値を取得し、最大のもののみを保持
        tmp = href[pos + 4, href.length].to_i
        if tmp > eid
          eid = tmp
        end
      }
    
      @@maxEid = eid
    
      # 最大のeidをreturn
      return eid
    end
    
    # 最大のeid以下の数値を取得する
    def getRandomId
      maxId = getMaxEid
    
      # シードは現在時間
      srand Time.now.to_i
      return rand(maxId) + 1
    end
    
    # 各ページのURLを取得
    def getEachPageUrl(eid)
        return @@url + '?eid=' + eid.to_s
    end
    
    # ランダムなeidのページに有る画像のURLを取得する
    # 取得に失敗した場合、再度自分を呼び出す
    def getImage(eid)
      # 各ページを取得
      eachPageUrl = getEachPageUrl(eid)
      html = Nokogiri::HTML(open(eachPageUrl, 'r:euc-jp').read.encode('utf-8'))
    
      # imgタグでpictクラスのものを取得
      pict = html.css('img.pict')
    
      # 取得できていなかった場合、再度試行
      unless pict[0]
        return getImage(getRandomId)
      end
    
      # return
      return [ pict[0]['src'], eachPageUrl ]
    end
end
