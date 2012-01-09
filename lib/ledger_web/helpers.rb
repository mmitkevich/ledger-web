module LedgerWeb
  module Helpers

    def partial (template, locals = {})
      erb(template, :layout => false, :locals => locals)
    end
  
    def table(report, options = {})
      links = options[:links] || {}
      partial(:table, :report => report, :links => links)
    end
  
    def query(options={}, &block)
      q = capture(&block)
      report = LedgerWeb::Report.from_query(q)
      if options[:pivot]
        report = report.pivot(options[:pivot], options[:pivot_sort_order])
      end
      return report
    end
  
    def expect(expected)
      not_present = []
      expected.each do |key|
        if not params.has_key? key
          not_present << key
        end
      end
  
      if not_present.length > 0
        raise "Missing params: #{not_present.join(', ')}"
      end
    end
  
    def linkify(links, row, value, display_value)
      links.each do |key, val|
        if key.is_a? String
          key = /^#{key}$/
        end
  
        if key.match(value[1].title.to_s)
          url = String.new(links[key])
          row.each_with_index do |v,i|
            url.gsub!(":#{i}", v[0].to_s)
          end
  
          url.gsub!(':title', value[1].title.to_s)
          display_value = "<a href='#{url}'>#{display_value}</a>"
        end
      end
      display_value
    end

    def visualization(report, options={}, &block)
      vis = capture(&block)
      @vis_count ||= 0
      @vis_count += 1
      @_out_buf.concat(
        partial(
          :visualization,
          :report => report,
          :visualization_code => vis, 
          :div_id => "vis_#{@vis_count}"
        )
      )
    end
  end
end

