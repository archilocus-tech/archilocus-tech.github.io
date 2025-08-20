module Jekyll
  module SpeakerUtils
    # Normalize speaker name for deduplication
    def normalize_name(name)
      return "" if name.nil?
      name.to_s.downcase.strip.gsub(/[^a-z0-9]/, '')
    end

    # Extract speakers from agenda items (handles both 'speakers' array and legacy 'speaker' formats)
    def extract_speakers_from_agenda(agenda)
      speakers_map = {}

      agenda.each do |agenda_item|
        next unless agenda_item.is_a?(Hash)

        # Handle 'speakers' array (current format)
        if agenda_item['speakers'] && agenda_item['speakers'].is_a?(Array)
          agenda_item['speakers'].each do |speaker|
            next unless speaker.is_a?(Hash) && speaker['name'] && !speaker['name'].empty?

            speaker_key = normalize_name(speaker['name'])
            speakers_map[speaker_key] = extract_speaker_data(speaker)
          end
        end

        # Handle 'speaker' (legacy format - single speaker or array)
        if agenda_item['speaker']
          if agenda_item['speaker'].is_a?(Hash)
            speaker = agenda_item['speaker']
            if speaker['name'] && !speaker['name'].empty?
              speaker_key = normalize_name(speaker['name'])
              speakers_map[speaker_key] = extract_speaker_data(speaker)
            end
          elsif agenda_item['speaker'].is_a?(Array)
            agenda_item['speaker'].each do |speaker|
              next unless speaker.is_a?(Hash) && speaker['name'] && !speaker['name'].empty?

              speaker_key = normalize_name(speaker['name'])
              speakers_map[speaker_key] = extract_speaker_data(speaker)
            end
          end
        end
      end

      speakers_map
    end

    # Extract basic speaker data (name, position, logos, etc.)
    def extract_speaker_data(speaker)
      {
        'name' => speaker['name'],
        'position' => speaker['position'],
        'company_logo' => speaker['company_logo'],
        'img' => speaker['img']
      }
    end

    # Collect speakers with associated talks for cross-session analysis
    def collect_speakers_with_talks(site_data)
      speakers_map = {}

      site_data.each do |key, value|
        next unless key.match(/^\d{4}_\d{2}$/) && value.is_a?(Hash)

        year = key.split('_')[0]
        month = key.split('_')[1]
        session_url = "/#{year}/#{month}"

        if value['agenda']
          value['agenda'].each do |agenda_item|
            next unless agenda_item.is_a?(Hash)

            # Create talk data
            talk = {
              title: agenda_item['title'],
              topic: agenda_item['topic'],
              video_url: agenda_item['video_url'],
              session_url: session_url,
              session_date: "#{year}/#{month}"
            }

            # Process speakers from current format
            if agenda_item['speakers'] && agenda_item['speakers'].is_a?(Array)
              agenda_item['speakers'].each do |speaker|
                next unless speaker.is_a?(Hash) && speaker['name'] && !speaker['name'].empty?
                add_speaker_with_talk(speakers_map, speaker, talk, key)
              end
            end

            # Process speakers from legacy format
            if agenda_item['speaker']
              if agenda_item['speaker'].is_a?(Hash)
                speaker = agenda_item['speaker']
                if speaker['name'] && !speaker['name'].empty?
                  add_speaker_with_talk(speakers_map, speaker, talk, key)
                end
              elsif agenda_item['speaker'].is_a?(Array)
                agenda_item['speaker'].each do |speaker|
                  next unless speaker.is_a?(Hash) && speaker['name'] && !speaker['name'].empty?
                  add_speaker_with_talk(speakers_map, speaker, talk, key)
                end
              end
            end
          end
        end
      end

      speakers_map.values.sort_by { |s| s[:name] }
    end

    private

    def add_speaker_with_talk(speakers_map, speaker, talk, session_key)
      speaker_key = normalize_name(speaker['name'])

      if !speakers_map[speaker_key] || is_more_recent?(session_key, speakers_map[speaker_key][:session_key])
        # Preserve existing talks during update
        existing_talks = speakers_map[speaker_key] ? speakers_map[speaker_key][:talks] : []

        speakers_map[speaker_key] = {
          name: speaker['name'],
          position: speaker['position'],
          company_logo: speaker['company_logo'],
          img: speaker['img'],
          session_key: session_key,
          session_url: talk[:session_url],
          talks: existing_talks
        }

        # Add current talk if not already present
        unless existing_talks.any? { |t| t[:title] == talk[:title] && t[:session_url] == talk[:session_url] }
          speakers_map[speaker_key][:talks] << talk
        end
      else
        # Existing speaker, just add the talk if not already present
        unless speakers_map[speaker_key][:talks].any? { |t| t[:title] == talk[:title] && t[:session_url] == talk[:session_url] }
          speakers_map[speaker_key][:talks] << talk
        end
      end
    end

    def is_more_recent?(key1, key2)
      key1 > key2
    end
  end
end