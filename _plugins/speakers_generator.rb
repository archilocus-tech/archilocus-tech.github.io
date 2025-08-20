require_relative 'speaker_utils'

module Jekyll
  class SpeakersPageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      puts "🔍 [DEBUG] Generating speakers page..."
      # Create the speakers page
      site.pages << SpeakersPage.new(site, site.source)
      puts "✅ [DEBUG] Speakers page created"
    end
  end

  class SpeakersPage < Page
    include SpeakerUtils
    def initialize(site, base)
      puts "🔍 [DEBUG] Initializing SpeakersPage..."
      @site = site
      @base = base
      @dir = '/speakers'
      @name = 'index.html'

      self.process(@name)

      self.data ||= {}
      self.data['layout'] = 'default'
      self.data['title'] = 'Tous nos speakers'
      self.data['permalink'] = '/speakers/'

      puts "🔍 [DEBUG] Collecting speakers..."
      all_speakers = collect_speakers_with_talks(site.data)
      debug_speakers_collection(all_speakers)
      puts "✅ [DEBUG] #{all_speakers.size} speakers collected"

      puts "🔍 [DEBUG] Assigning speaker data..."
      self.data['all_speakers'] = process_speaker_data(all_speakers)
      
      # Use includes for HTML generation instead of inline HTML
      self.content = "{% include speakers_page.html %}{% include speakers_page_scripts.html %}"
      puts "✅ [DEBUG] Data assigned and content configured"
    end

    private

    def debug_speakers_collection(speakers)
      puts "🔍 [DEBUG] Sorting speakers by name..."
      
      # Final debug
      puts "📊 [DEBUG] Final summary:"
      speakers.each do |speaker|
        puts "  - #{speaker[:name]} (#{speaker[:talks].size} talks)"
        speaker[:talks].each do |talk|
          puts "    * #{talk[:title]} (#{talk[:session_date]})"
        end
      end
    end

    def process_speaker_data(speakers)
      puts "🔍 [DEBUG] Processing data for #{speakers.size} speakers"
      
      speakers.map.with_index do |speaker, index|
        puts "  🎨 [DEBUG] Processing speaker #{index + 1}/#{speakers.size}: #{speaker[:name]}"
        
        img_path = speaker[:img] ? find_speaker_image(speaker[:img], speaker[:session_key]) : '/css/img/TBD.jpg'
        logo_path = speaker[:company_logo] ? find_company_logo(speaker[:company_logo], speaker[:session_key]) : ''

        puts "    🖼️  [DEBUG] Image: #{img_path}"
        puts "    🏢 [DEBUG] Logo: #{logo_path}" unless logo_path.empty?

        {
          'name' => speaker[:name],
          'position' => speaker[:position],
          'img_path' => img_path,
          'logo_path' => logo_path,
          'talks' => speaker[:talks].map do |talk|
            {
              'title' => talk[:title],
              'video_url' => talk[:video_url],
              'session_url' => talk[:session_url],
              'session_date' => talk[:session_date]
            }
          end
        }
      end
    end

    def find_speaker_image(img_filename, preferred_session_key = nil)
      puts "    🔍 [DEBUG] Searching for image: #{img_filename}"

      # Try first in preferred session folder
      if preferred_session_key
        preferred_path = "/css/#{preferred_session_key}/img/speaker/#{img_filename}"
        puts "      📂 [DEBUG] Preferred path: #{preferred_path}"
        if File.exist?(@site.source + preferred_path)
          puts "      ✅ [DEBUG] Found in preferred session"
          return preferred_path
        end
      end

      # Otherwise, search in all folders
      Dir.glob(@site.source + "/css/*/img/speaker/#{img_filename}").first&.sub(@site.source, '') ||
      Dir.glob(@site.source + "/css/team/#{img_filename}").first&.sub(@site.source, '') ||
      '/css/img/TBD.jpg'
    end

    def find_company_logo(logo_filename, preferred_session_key = nil)
      return '' if logo_filename.nil?
      puts "    🔍 [DEBUG] Searching for logo: #{logo_filename}"

      # Try first in preferred session folder
      if preferred_session_key
        preferred_path = "/css/#{preferred_session_key}/img/logos/#{logo_filename}"
        puts "      📂 [DEBUG] Preferred path: #{preferred_path}"
        if File.exist?(@site.source + preferred_path)
          puts "      ✅ [DEBUG] Logo found in preferred session"
          return preferred_path
        end
      end

      # Otherwise, search in all folders
      found_path = Dir.glob(@site.source + "/css/*/img/logos/#{logo_filename}").first&.sub(@site.source, '')
      puts "      #{found_path ? '✅' : '❌'} [DEBUG] Logo #{found_path ? 'found' : 'not found'}: #{found_path}"
      found_path || ''
    end
  end
end
