#!/usr/bin/env ruby

class GroupRows
#module GroupRows

  attr_accessor :create_sql, :dbs, :sqls, :glob

  def initialize(db_glob)
    @glob = db_glob
    #setup
    get_dbs
    extract_sql_from_dbs
    get_create_sql
    remove_creates
  end

  def setup
    delete = nil
    create_sql = nil
    dbs = (get_dbs + get_dbs).map do |f|
      sql = db_sql(f)
      create_sql ||= get_create_sql(sql)
      sql.tap{|o|
        o = remove_create_sql o, delete
        delete ||= true
      }
    end
    GroupRows.new(@create_sql, dbs)
  end

  def get_dbs
    @dbs ||= Dir.glob(@glob)
  end

  def extract_sql_from_dbs
    @sqls ||= @dbs.map{|f|
      IO.popen("echo '.dump Messages' | sqlite3 '#{f}' | sed 's/Messages/messages/;s/BLOG/text/;s/INTEGER/bigint/g' | tail +2").read
    }
  end

  def get_create_sql
    @create_sql ||= sqls.first[/^create table.*/i]
  end

  def remove_creates
    delete = nil
    @sqls.each do |f|
      f.gsub!(/^create table.*/i, '') if delete
      delete ||= true
    end
  end
end

gr = GroupRows.new('/Users/jearsh/Library/Appli*ort/Skype/*/main.db')

puts gr.sqls.count
puts gr.sqls.map{|x| x.split(/\n/)[1]}



