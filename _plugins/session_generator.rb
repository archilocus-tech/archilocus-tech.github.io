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

        # Collect speakers from agenda
        self.data['speakers'] = collect_speakers_from_agenda(data['agenda'])
        self.data['speakers_count'] = self.data['speakers'].length
      end

      self.content = "{% include agenda.html directory=page.data_directory date=page.session_date %}{% include speakers.html %}"
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

    def collect_speakers_from_agenda(agenda)
      speakers_map = {}

      agenda.each do |agenda_item|
        next unless agenda_item.is_a?(Hash)

        # Handle 'speakers' array (current format)
        if agenda_item['speakers'] && agenda_item['speakers'].is_a?(Array)
          agenda_item['speakers'].each do |speaker|
            next unless speaker.is_a?(Hash) && speaker['name'] && !speaker['name'].empty?

            speaker_key = normalize_name(speaker['name'])
            speakers_map[speaker_key] = {
              'name' => speaker['name'],
              'position' => speaker['position'],
              'company_logo' => speaker['company_logo'],
              'img' => speaker['img']
            }
          end
        end

        # Handle 'speaker' (legacy format - single speaker or array)
        if agenda_item['speaker']
          if agenda_item['speaker'].is_a?(Hash)
            speaker = agenda_item['speaker']
            if speaker['name'] && !speaker['name'].empty?
              speaker_key = normalize_name(speaker['name'])
              speakers_map[speaker_key] = {
                'name' => speaker['name'],
                'position' => speaker['position'],
                'company_logo' => speaker['company_logo'],
                'img' => speaker['img']
              }
            end
          elsif agenda_item['speaker'].is_a?(Array)
            agenda_item['speaker'].each do |speaker|
              next unless speaker.is_a?(Hash) && speaker['name'] && !speaker['name'].empty?

              speaker_key = normalize_name(speaker['name'])
              speakers_map[speaker_key] = {
                'name' => speaker['name'],
                'position' => speaker['position'],
                'company_logo' => speaker['company_logo'],
                'img' => speaker['img']
              }
            end
          end
        end
      end

      # Return sorted array of unique speakers
      speakers_map.values.sort_by { |s| s['name'] }
    end

    def normalize_name(name)
      return "" if name.nil?
      name.to_s.downcase.strip.gsub(/[^a-z0-9]/, '')
    end
  end
end
