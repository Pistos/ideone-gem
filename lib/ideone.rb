require 'json'
require 'net/http'
require 'cgi'


module Ideone

  class IdeoneError < StandardError; end

  LANGUAGES = {
    :ruby   => 17,
    :python => 4,
    :c      => 11
  }
  TIMEOUT = 7   # seconds

  def self.submit( lang, code )
    if ! LANGUAGES.keys.include?( lang )
      raise "Invalid language: #{lang}"
    end

    Net::HTTP.post_form(
      URI.parse("http://ideone.com/ideone/Index/submit/"),
      {
        'lang' => LANGUAGES[lang],
        'run'  => 0,
        'file' => code
      }
    ).header['location'][1..-1]
  end

  def self.run( id, input )
    res = JSON.load(
      Net::HTTP.post_form(
        URI.parse( "http://ideone.com/submit/parent/#{id}" ),
        { 'input' => input }
      ).body
    )
    if res['status'] != 'ok'
      raise IdeoneError, "Posting of input failed."
    end

    loc = res['link']
    i = 0

    begin
      sleep 1  if i > 0
      res = JSON.load(
        Net::HTTP.post_form(
          URI.parse("http://ideone.com/ideone/Index/view/id/#{loc}/ajax/1"),
          {}
        ).body
      )
      i += 1
    end while res['result'] != "15" && i < TIMEOUT

    if i == TIMEOUT
      raise IdeoneError, "Timed out while waiting for code result."
    end

    err = res['inouterr'].match(/<label>stderr:<\/label>.*?<pre.*?>(.*?)<\/pre>/m)
    if err
      err[1]
    else
      out = res['inouterr'].match(/<label>output:<\/label>.*?<pre.*?>(.*?)<\/pre>/m)
      if out
        out[1]
      else
        raise IdeoneError, "Error parsing output."
      end
    end
  end

end
