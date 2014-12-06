#!/usr/bin/env ruby

require "fileutils"
require "net/http"
require "uri"

require "./common"

FileUtils.mkdir_p("data")

YEARS.product(MONTHS) do |pair|
  year, month = *pair
  basename = "#{year}-#{month}.txt"
  output_path = File.join("data", basename)
  if File.exist?(output_path)
    $stderr.puts("#{basename} is already exists.")
    next
  end

  uri = URI.parse("#{HOST_NAME}#{BASE_PATH}#{basename}")
  res = nil
  5.times do
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.request_uri)
    end

    case res
    when Net::HTTPSuccess
      break
    when Net::HTTPRedirection
      uri = URI.parse(res["Location"])
      next
    else
      break
    end
  end
  sleep 0.5
  unless res.is_a?(Net::HTTPSuccess)
    $stderr.puts("#{basename} is not found.")
    next
  end

  File.open(output_path, "w") do |input_file|
    euc_text = res.body
    input_file.write(euc_text.encode("UTF-8", "EUC-JP"))
  end
end
