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
  TIMEOUT = 4   # seconds

  def self.submit( lang_, code )
    lang = LANGUAGES[ lang_ ] || lang_

    Net::HTTP.post_form(
      URI.parse("http://ideone.com/ideone/Index/submit/"),
      {
        'lang' => LANGUAGES[lang],
        'run'  => 0,
        'file' => code
      }
    ).header['location'][1..-1]
  end

  def self.run( id, input, timeout = TIMEOUT )
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
      sleep 3  if i > 0
      res = JSON.load(
        Net::HTTP.post_form(
          URI.parse("http://ideone.com/ideone/Index/view/id/#{loc}/ajax/1"),
          {}
        ).body
      )
      i += 1
    end while res['status'] != '0' && i < timeout

    case res[ 'result' ]
      when '0', '15'
        # success
      when '11'
        raise IdeoneError, "Compilation error"
      when '12'
        raise IdeoneError, "Runtime error"
      when '13'
        raise IdeoneError, "Execution timed out"
      when '17'
        raise IdeoneError, "Memory limit exceeded"
      when '19'
        raise IdeoneError, "Illegal system call"
      when '20'
        raise IdeoneError, "Internal error occurred at ideone.com"
      else
        raise IdeoneError, "Unknown result: " + res[ 'result' ]
    end

    if i == timeout
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
