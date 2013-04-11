#!/usr/bin/env ruby

class GroupRows
#module GroupRows

  attr_accessor :create_sql, :dbs, :sqls, :glob

  def initialize(db_glob)
    @glob = db_glob
    setup
  end

  def setup
    get_dbs
    extract_sql_from_dbs
    get_create_sql

    # TODO
    create_temp_db
    load_sql
  end

  def create_temp_db
    # write system(createdb tempname)
  end

  def load_sql
    # write system(psql <sqls.join)
  end

  def get_dbs
    @dbs ||= Dir.glob(@glob)
  end

  def extract_sql_from_dbs
    @sqls ||= @dbs.each_with_index.map{|db,i|
      sql = IO.popen("echo '.dump Messages' | sqlite3 '#{db}' | sed 's/Messages/messages/;s/BLOG/text/;s/INTEGER/bigint/g' | tail +2").read.tap{|s|
        remove_create(s) if i > 0
      }
    }
  end

  def get_create_sql
    @create_sql ||= sqls.first[/^create table.*/i]
  end

  def remove_create(f)
    f.gsub!(/^create table.*/i, '')
  end
end

gr = GroupRows.new('/Users/jearsh/Library/Appli*ort/Skype/*/main.db')

puts gr.sqls.count
puts gr.sqls.map{|x| x.split(/\n/).first(2).map{|z| z[0,30]}}



