class RecordController < ApplicationController

  def find
    @books = Book.all
    render 'hello/list'
  end

  def find_by
    @books = Book.find_by(publish: '技術評論社')
    render 'books/show'
  end

  def find_by2
    @books = Book.find_by(publish: '技術評論社', price: 2919)
    render 'books/show'
  end

  def where
    @books = Book.where(publish: '技術評論社')
    render 'hello/list'
  end

  def where2
    @books = Book.all
    @books.where!(publish: '技術評論社')
    @books.order!(:published)
    render 'books/index'
  end

  def ph1
    @books = Book.where('publish :publish AND price >= :price', publish: params[:publish], price: params[:price])
    render 'hello/list'
  end

  def not
    @books = Book.where.not(isbn: params[:id])
    render 'books/index'
  end

  def order
    @books = Book.where(publish: '技術評論社').order(published: :desc)
    render 'hello/list'
  end

  def reorder
    @books = Book.order(:publish).order(:price)
    render 'books/index'
  end

  def select
    @books = Book.where('price >= 2000').select(:title, :price)
    render 'hello/list'
  end

  def select2
    @pubs = Book.select(:publish).distinct.order(:publish)
  end

  def offset
    @books = Book.order(published: :desc).limit(3).offset(4)
    render 'hello/list'
  end

  def page
    page_size = 3
    page_num = params[:id] == nil ? 0 : params[:id].to_i - 1       # 現在のページ数
    @books = Book.order(published: :desc).limit(page_size).offset(page_size * page_num)
    render 'hello/list'
  end

  def last
    @books = Book.order(published: :desc).last
    render 'books/show'
  end

  def groupby
    @books = Book.select('publish, AVG(price) AS avg_price' ).group(:publish)
  end

  def groupby2
    @books = Book.group(:publish).average(:price)
  end

  def havingby
    @books = Book.select('publish, AVG(price) AS avg_price').group(:publish).having('AVG(price) >= ?', 2500)
    render 'record/groupby'
  end

  def scope
    @books = Book.gihyo.top10
    render 'hello/list'
  end

  def scope2
    @books = Book.whats_new('技術評論社')
    render 'hello/list'
  end

  def unscope 
    @books = Book.where(publish: '技術評論社').order(:price).select(:isbn, :title).unscope(:where, :select)
    render 'books/index'
  end

  def unscope2 
    @books = Book.where(publish: '技術評論社', cd: true).order(:price).unscope(where: :cd)
    render 'books/index'
  end

  def def_scope
    render text: Review.all.inspect
  end

  def none 
    case params[:id]
      when 'all'
        @books = Book.all
      when 'new'
        @books = Book.order('published DESC').limit(5)
      when 'cheap'
        @books = Book.order('price').limit(5)
      else
        @books = Book.none
    end
    render 'books/index'
  end

  def pluck
    render text: Book.where(publish: '技術評論社').pluck(:title, :price)
  end

  def exists
    flag = Book.where(publish: '新評論社').exists?
    render text: "存在するか？：#{flag}"
  end

  def count
    cnt = Book.where(publish: '技術評論社').count
    render text: "#{cnt}件です。"
  end

  def average
    price = Book.where(publish: '技術評論社').average(:price)
    render text: "平均価格は#{price}円です。"
  end

  def literal_sql
    @books = Book.find_by_sql(['SELECT publish, AVG(price) AS avg_price FROM "books" GROUP BY publish HAVING AVG(price) >= ?', 2500])
    render 'record/groupby'
  end

  def update_all
    cnt = Book.where(publish: '技術評論社').update_all(publish: 'Gihyo')
    render text: "#{cnt}件のデータを更新しました。"
  end

  def update_all2
    cnt = Book.order(:published).limit(5).update_all('price = price * 0.8')
    render text: "#{cnt}件のデータを更新しました。"
  end

  def destroy_all
    Book.destory_all(['publish <> ?', '技術評論社'])
    render text: '削除完了'
  end

  def transact
      Book.transaction do
        b1 = Book,new({isbn: '978-4-7741--4223-0',
          title: 'Rubyポケットリファレンス',
          price: 2000,publish: '技術評論社',published: '2011-01-01'})
        b1.save!
        raise '例外処理発生：処理はキャンセルされました。'
        b2 = Book,new({isbn: '978-4-7741--4223-2',
          title: 'Tomcatポケットリファレンス',
          price: 2500,publish: '技術評論社',published: '2011-01-01'})
        b2.save!
      end
      render text: 'トランザクションは成功しました。'
    rescue => e
      render text: e.message
  end

  def keywd
    @search = SearchKeyword.new
  end
end