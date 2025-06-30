module Jekyll
  class SessionPageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site.data.each do |key, value|
        if key.match(/^\d{4}_\d{2}$/) && value.is_a?(Hash) && value['agenda']
          year = key.split('_')[0]
          month = key.split('_')[1]
          site.pages << SessionPage.new(site, site.source, key, year, month, value)
        end
      end
    end
  end

  class SessionPage < Page
    def initialize(site, base, data_key, year, month, data)
      @site = site
      @base = base
      @dir = "/#{year}/#{month}"
      @name = 'index.html'

      self.process(@name)

      self.data ||= {}
      self.data['layout'] = 'default'

      if data['agenda'] && data['agenda'].any?
        session_title = data['session_title'] || "Session #{format_date(year, month)}"
        session_date = data['session_date'] || format_date(year, month)

        self.data['title'] = session_title
        self.data['session_date'] = session_date
        self.data['data_directory'] = data_key
      end

      self.content = "{% include agenda.html directory=page.data_directory date=page.session_date %}"
    end

    private

    def format_date(year, month)
      months = {
        '01' => 'Janvier', '02' => 'Février', '03' => 'Mars',
        '04' => 'Avril', '05' => 'Mai', '06' => 'Juin',
        '07' => 'Juillet', '08' => 'Août', '09' => 'Septembre',
        '10' => 'Octobre', '11' => 'Novembre', '12' => 'Décembre'
      }
      "Session #{months[month]} #{year}"
    end
  end
end
