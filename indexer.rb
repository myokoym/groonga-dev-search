require "grn_mini"
require "fileutils"
require "mail"

require "./config"

FileUtils.mkdir_p(DB_DIR)

db_path = File.join(DB_DIR, "groonga-dev-search.db")

GrnMini.create_or_open(db_path)
hash = GrnMini::Hash.new

Dir.glob("#{DATA_DIR}/*") do |path|
  index_by_month = 0
  basename = File.basename(path, ".txt")
  year, month = basename.split(/-/)
  File.open(path) do |file|
    text = ""
    file.each_line do |line|
      case line
      when /^From /
        next if text.empty?
        mail = Mail.new(text)
        text = ""
        index_by_month += 1
        key = "#{basename}-#{"%04d" % index_by_month}"
        hash[key] = {
          :from    => mail.from,
          :date    => mail.date.to_s,
          :subject => mail.subject,
          :body    => mail.body.to_s.force_encoding("UTF-8"),
        }
      else
        text << line
      end
    end
  end
end
