module Jekyll
  class SpeakersPageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      puts "🔍 [DEBUG] Génération de la page speakers..."
      # Créer la page speakers
      site.pages << SpeakersPage.new(site, site.source)
      puts "✅ [DEBUG] Page speakers créée"
    end
  end

  class SpeakersPage < Page
    def initialize(site, base)
      puts "🔍 [DEBUG] Initialisation SpeakersPage..."
      @site = site
      @base = base
      @dir = '/speakers'
      @name = 'index.html'

      self.process(@name)

      self.data ||= {}
      self.data['layout'] = 'default'
      self.data['title'] = 'Tous nos speakers'
      self.data['permalink'] = '/speakers/'

      puts "🔍 [DEBUG] Collecte des speakers..."
      all_speakers = collect_all_speakers(site)
      puts "✅ [DEBUG] #{all_speakers.size} speakers collectés"

      puts "🔍 [DEBUG] Génération du HTML..."
      self.content = generate_speakers_html(all_speakers)
      puts "✅ [DEBUG] HTML généré (#{self.content.length} caractères)"
    end

    private

    def collect_all_speakers(site)
      speakers_map = {}

      puts "🔍 [DEBUG] Parcours des données site..."
      site.data.each do |key, value|
        next unless key.match(/^\d{4}_\d{2}$/) && value.is_a?(Hash)

        puts "  📁 [DEBUG] Traitement de #{key}"
        year = key.split('_')[0]
        month = key.split('_')[1]
        session_url = "/#{year}/#{month}"

        if value['agenda']
          puts "    📅 [DEBUG] #{value['agenda'].size} items agenda trouvés dans #{key}"
          value['agenda'].each do |agenda_item|
            next unless agenda_item.is_a?(Hash) && agenda_item['speakers']

            agenda_item['speakers'].each do |speaker|
              # Ignorer les speakers sans nom ou avec nom vide
              next unless speaker.is_a?(Hash) && speaker['name'] && !speaker['name'].empty?

              speaker_key = normalize_name(speaker['name'])

              # Créer le talk associé
              talk = {
                title: agenda_item['title'],
                topic: agenda_item['topic'],
                video_url: agenda_item['video_url'],
                session_url: session_url,
                session_date: "#{year}/#{month}"
              }

              if !speakers_map[speaker_key] || is_more_recent?(key, speakers_map[speaker_key][:session_key])
                puts "  ⚠        ➕ [DEBUG] Ajout/Mise à jour: #{speaker['name']}"

                # Préserver les talks existants lors de la mise à jour
                existing_talks = speakers_map[speaker_key] ? speakers_map[speaker_key][:talks] : []

                speakers_map[speaker_key] = {
                  name: speaker['name'],
                  position: speaker['position'],
                  company_logo: speaker['company_logo'],
                  img: speaker['img'],
                  session_key: key,
                  session_url: session_url,
                  talks: existing_talks  # Préserver les talks existants
                }

                # Ajouter le talk actuel
                unless existing_talks.any? { |t| t[:title] == talk[:title] && t[:session_url] == talk[:session_url] }
                  speakers_map[speaker_key][:talks] << talk
                  puts "      🎤 [DEBUG] Talk ajouté à #{speaker['name']}: #{agenda_item['title']} (total: #{speakers_map[speaker_key][:talks].size})"
                end
              else
                # Speaker existant mais ancien, ajouter juste le talk
                unless speakers_map[speaker_key][:talks].any? { |t| t[:title] == talk[:title] && t[:session_url] == talk[:session_url] }
                  speakers_map[speaker_key][:talks] << talk
                  puts "      🎤 [DEBUG] Talk ajouté à #{speaker['name']}: #{agenda_item['title']} (total: #{speakers_map[speaker_key][:talks].size})"
                else
                  puts "      🔄 [DEBUG] Talk déjà présent pour #{speaker['name']}: #{agenda_item['title']}"
                end
              end
            end
          end
        else
          puts "    ❌ [DEBUG] Pas d'agenda dans #{key}"
        end

        # Gérer aussi les speakers au format 'speaker' (singulier) - format legacy
        if value['agenda']
          value['agenda'].each do |agenda_item|
            next unless agenda_item.is_a?(Hash) && agenda_item['speaker']

            speaker = agenda_item['speaker']

            if speaker.is_a?(Hash)
              next unless speaker['name'] && !speaker['name'].empty?
              speaker_key = normalize_name(speaker['name'])

              talk = {
                title: agenda_item['title'],
                topic: agenda_item['topic'],
                video_url: agenda_item['video_url'],
                session_url: session_url,
                session_date: "#{year}/#{month}"
              }

              if speakers_map[speaker_key]
                unless speakers_map[speaker_key][:talks].any? { |t| t[:title] == talk[:title] && t[:session_url] == talk[:session_url] }
                  speakers_map[speaker_key][:talks] << talk
                  puts "      🎤 [DEBUG] Talk ajouté à #{speaker['name']}: #{agenda_item['title']} (total: #{speakers_map[speaker_key][:talks].size})"
                end
              else
                puts "      👤 [DEBUG] Nouveau speaker depuis agenda (legacy): #{speaker['name']}"
                speakers_map[speaker_key] = {
                  name: speaker['name'],
                  position: speaker['position'],
                  company_logo: speaker['company_logo'],
                  img: speaker['img'],
                  session_key: key,
                  session_url: session_url,
                  talks: [talk]
                }
              end
            elsif speaker.is_a?(Array)
              # Format où speaker est un array
              speaker.each do |sp|
                next unless sp.is_a?(Hash) && sp['name'] && !sp['name'].empty?
                speaker_key = normalize_name(sp['name'])

                talk = {
                  title: agenda_item['title'],
                  topic: agenda_item['topic'],
                  video_url: agenda_item['video_url'],
                  session_url: session_url,
                  session_date: "#{year}/#{month}"
                }

                if speakers_map[speaker_key]
                  unless speakers_map[speaker_key][:talks].any? { |t| t[:title] == talk[:title] && t[:session_url] == talk[:session_url] }
                    speakers_map[speaker_key][:talks] << talk
                    puts "      🎤 [DEBUG] Talk ajouté à #{sp['name']}: #{agenda_item['title']} (total: #{speakers_map[speaker_key][:talks].size})"
                  end
                else
                  puts "      👤 [DEBUG] Nouveau speaker depuis agenda (array): #{sp['name']}"
                  speakers_map[speaker_key] = {
                    name: sp['name'],
                    position: sp['position'],
                    company_logo: sp['company_logo'],
                    img: sp['img'],
                    session_key: key,
                    session_url: session_url,
                    talks: [talk]
                  }
                end
              end
            end
          end
        end
      end

      puts "🔍 [DEBUG] Tri des speakers par nom..."
      # Trier par nom
      sorted_speakers = speakers_map.values.sort_by { |s| s[:name] }

      # Debug final
      puts "📊 [DEBUG] Résumé final:"
      sorted_speakers.each do |speaker|
        puts "  - #{speaker[:name]} (#{speaker[:talks].size} talks)"
        speaker[:talks].each do |talk|
          puts "    * #{talk[:title]} (#{talk[:session_date]})"
        end
      end

      sorted_speakers
    end

    def normalize_name(name)
      return "" if name.nil?
      name.downcase.gsub(/[^a-z0-9]/, '')
    end

    def is_more_recent?(key1, key2)
      key1 > key2
    end

    def generate_speakers_html(speakers)
      puts "🔍 [DEBUG] Génération HTML pour #{speakers.size} speakers"
      html = <<~HTML
        <section id="all-speakers" class="bg-light-gray">
          <div class="container">
            <div class="row">
              <div class="col-lg-12 text-center">
                <h2 class="section-heading">Tous nos speakers</h2>
                <h3 class="section-subheading text-muted">#{speakers.size} intervenants depuis 2021</h3>
              </div>
            </div>
            <div class="row">
      HTML

      speakers.each_with_index do |speaker, index|
        puts "  🎨 [DEBUG] Génération HTML speaker #{index + 1}/#{speakers.size}: #{speaker[:name]}"
        img_path = speaker[:img] ? find_speaker_image(speaker[:img], speaker[:session_key]) : '/css/img/TBD.jpg'
        logo_path = speaker[:company_logo] ? find_company_logo(speaker[:company_logo], speaker[:session_key]) : ''

        puts "    🖼️  [DEBUG] Image: #{img_path}"
        puts "    🏢 [DEBUG] Logo: #{logo_path}" unless logo_path.empty?

        html += <<~HTML
          <div class="col-md-4 col-sm-6 speaker-item">
            <div class="speaker-card">
              <img class="speaker-photo" src="#{img_path}" alt="#{speaker[:name]}" onerror="this.src='/css/img/TBD.jpg'">
              <h4 class="speaker-name">#{speaker[:name]}</h4>
              <div class="speaker-position">#{speaker[:position]}</div>
        HTML

        if !logo_path.empty?
          html += <<~HTML
            <img class="speaker-company-logo" src="#{logo_path}" alt="Company logo" onerror="this.style.display='none'">
          HTML
        end

        html += <<~HTML
              <div class="speaker-talks">
        HTML

        speaker[:talks].each do |talk|
          puts "    🎤 [DEBUG] Talk: #{talk[:title]} (vidéo: #{talk[:video_url] ? 'oui' : 'non'})"
          if talk[:video_url]
            html += <<~HTML
              <div class="talk-item">
                <div class="talk-title">#{talk[:title]}</div>
                <div class="talk-actions">
                  <a href="#{talk[:session_url]}" class="btn btn-outline btn-xs">📅 #{talk[:session_date]}</a>
                  <a href="#" onclick="openVideoModal('#{talk[:video_url]}', '#{talk[:title].gsub("'", "\\'")}'); return false;" class="btn btn-primary btn-xs">🎥 Vidéo</a>
                </div>
              </div>
            HTML
          end
        end

        html += <<~HTML
              </div>
            </div>
          </div>
        HTML
      end

      html += <<~HTML
            </div>
          </div>
        </section>

        <!-- Modal vidéo -->
        <div id="videoModal" class="video-modal" onclick="closeVideoModal()">
          <div class="video-modal-content" onclick="event.stopPropagation()">
            <span class="video-modal-close" onclick="closeVideoModal()">&times;</span>
            <h3 id="videoTitle"></h3>
            <div id="videoContainer"></div>
          </div>
        </div>

        <style>
          .speaker-item {
            margin-bottom: 30px;
          }

          .speaker-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
          }

          .speaker-talks {
            margin-top: 15px;
            flex-grow: 1;
          }

          .talk-item {
            background: #f8f9fa;
            border-radius: 4px;
            padding: 10px;
            margin-bottom: 10px;
            text-align: left;
          }

          .talk-title {
            font-weight: bold;
            margin-bottom: 8px;
            font-size: 0.9em;
          }

          .talk-actions {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
          }

          .btn-xs {
            padding: 2px 8px;
            font-size: 0.8em;
          }

          .speaker-photo {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            margin: 0 auto 15px;
          }

          .speaker-name {
            margin-bottom: 5px;
            color: #333;
          }

          .speaker-position {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 10px;
          }

          .speaker-company-logo {
            height: 30px;
            max-width: 100px;
            object-fit: contain;
            margin: 10px auto;
          }

          .video-modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.8);
          }

          .video-modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 20px;
            border-radius: 8px;
            width: 80%;
            max-width: 800px;
            position: relative;
          }

          .video-modal-close {
            position: absolute;
            right: 10px;
            top: 10px;
            font-size: 24px;
            cursor: pointer;
          }

          #videoContainer iframe {
            width: 100%;
            height: 400px;
          }
        </style>

        <script>
          function openVideoModal(videoUrl, title) {
            document.getElementById('videoTitle').textContent = title;
            document.getElementById('videoContainer').innerHTML = '<iframe src="' + videoUrl + '" frameborder="0" allowfullscreen></iframe>';
            document.getElementById('videoModal').style.display = 'block';
          }

          function closeVideoModal() {
            document.getElementById('videoModal').style.display = 'none';
            document.getElementById('videoContainer').innerHTML = '';
          }
        </script>
      HTML

      html
    end

    def find_speaker_image(img_filename, preferred_session_key = nil)
      puts "    🔍 [DEBUG] Recherche image: #{img_filename}"

      # Essayer d'abord dans le dossier de la session préférée
      if preferred_session_key
        preferred_path = "/css/#{preferred_session_key}/img/speaker/#{img_filename}"
        puts "      📂 [DEBUG] Chemin préféré: #{preferred_path}"
        if File.exist?(@site.source + preferred_path)
          puts "      ✅ [DEBUG] Trouvé dans session préférée"
          return preferred_path
        end
      end

      # Sinon, chercher dans tous les dossiers
      Dir.glob(@site.source + "/css/*/img/speaker/#{img_filename}").first&.sub(@site.source, '') ||
      Dir.glob(@site.source + "/css/team/#{img_filename}").first&.sub(@site.source, '') ||
      '/css/img/TBD.jpg'
    end

    def find_company_logo(logo_filename, preferred_session_key = nil)
      return '' if logo_filename.nil?
      puts "    🔍 [DEBUG] Recherche logo: #{logo_filename}"

      # Essayer d'abord dans le dossier de la session préférée
      if preferred_session_key
        preferred_path = "/css/#{preferred_session_key}/img/logos/#{logo_filename}"
        puts "      📂 [DEBUG] Chemin préféré: #{preferred_path}"
        if File.exist?(@site.source + preferred_path)
          puts "      ✅ [DEBUG] Logo trouvé dans session préférée"
          return preferred_path
        end
      end

      # Sinon, chercher dans tous les dossiers
      found_path = Dir.glob(@site.source + "/css/*/img/logos/#{logo_filename}").first&.sub(@site.source, '')
      puts "      #{found_path ? '✅' : '❌'} [DEBUG] Logo #{found_path ? 'trouvé' : 'non trouvé'}: #{found_path}"
      found_path || ''
    end
  end
end
