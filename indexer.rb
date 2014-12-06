require "grn_mini"
require "fileutils"

require "./config"

FileUtils.mkdir_p(DB_DIR)

db_path = File.join(DB_DIR, "groonga-dev-search.db")

GrnMini.create_or_open(db_path)

Dir.glob("#{DATA_DIR}/*") do |path|
  index_by_month = 0
  basename = File.basename(path, ".txt")
  year, month = basename.split(/-/)
  File.open(path) do |file|
    key = nil
    hash = nil
    data = nil
    body = nil
    mode = :head
    file.each_line do |line|
      case line
      when /^From /
        data[:body] = body if body
        hash[key] = data if data

        index_by_month += 1
        key = "#{basename}-#{"%04d" % index_by_month}"
        hash = GrnMini::Hash.new
        data = {}
        body = ""
        mode = :head
      when /^From: (.*)/
        data[:from] = $1
      when /^Date: (.*)/
        data[:date] = $1
      when /^Subject: (.*)/
        data[:subject] = $1
      when /^Message-ID: (.*)/
        data[:"message-id"] = $1
        mode = :body
      else
        body << line
      end
    end
  end
end
