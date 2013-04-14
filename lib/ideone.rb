require 'json'
require 'net/http'
require 'cgi'

module Ideone

  class IdeoneError < StandardError; end

  LANGUAGES = {
    :bash       => 28,
    :c          => 11,
    'c#'        => 27,
    :csharp     => 27,
    'c++'       => 1,
    :cpp        => 1,
    :cplusplus  => 1,
    :clojure    => 111,
    :commonlisp => 32,
    :clisp      => 32,
    :erlang     => 36,
    :go         => 114,
    :haskell    => 21,
    :java       => 10,
    :javascript => 112,
    :js         => 112,
    :perl       => 3,
    :php        => 29,
    :python     => 4,
    :ruby       => 17,
    :lua        => 26,
    :tcl        => 38,
    :bf         => 12,
    :bc         => 110,
    :gawk       => 104,
    :nasm       => 13,
  }
  TIMEOUT = 4   # iterations

  def self.submit( lang_, code )
    lang = LANGUAGES[ lang_ ] || lang_

    Net::HTTP.post_form(
      URI.parse("http://ideone.com/ideone/Index/submit/"),
      {
        'lang' => lang,
        'run'  => 0,
        'file' => code,
        'public' => 0
      }
    ).header['location'][1..-1]
  end
  
  def self.error_message(res)
    err = res['inouterr'].match(/<label>stderr:<\/label>...<pre class="box">(.*)<\/pre>/m)
    err[1]  if err
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

    if i == timeout
      raise IdeoneError, "Timed out while waiting for code result."
    end

    case res[ 'result' ]
      when '0', '15'
        out = res['inouterr'].match(/output:<\/label>...<pre class="box">(.*)<\/pre>/m)
        if out
          CGI.unescapeHTML(out[1]) 
        end
      when '11'
        message = error_message(res)
        raise IdeoneError, "Compilation error: #{message}"        
      when '12'
        message = error_message(res)
        raise IdeoneError, "Runtime error: #{message}"
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

  end

end
