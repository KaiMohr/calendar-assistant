class CalendarAssistant
  module CLI
    class Printer
      EMOJI_WARN = "⚠"

      attr_reader :io

      def initialize io = STDOUT
        @io = io
      end

      def launch url
        Launchy.open url
      end

      def puts *args
        io.puts(*args)
      end

      def prompt query, default = nil
        loop do
          message = query
          message += " [#{default}]" if default
          message += ": "
          print Rainbow(message).bold
          answer = STDIN.gets.chomp.strip
          if answer.empty?
            return default if default
            puts Rainbow("Please provide an answer.").red
          else
            return answer
          end
        end
      end

      def print_now! ca, event, printed_now
        return true if printed_now
        return false if event.start_date != Date.today

        if event.start_time > Time.now
          puts event_description(CalendarAssistant::CLI::Helpers.now)
          return true
        end

        false
      end

      def print_events ca, event_set, omit_title: false
        unless omit_title
          er = event_set.event_repository
          puts Rainbow("#{er.calendar.id} (all times in #{er.calendar.time_zone})\n").italic
        end

        if event_set.is_a?(EventSet::Hash)
          event_set.events.each do |key, value|
            puts Rainbow(key.to_s.capitalize + ":").bold.italic
            print_events ca, event_set.new(value), omit_title: true
          end
          return
        end

        events = Array(event_set.events)
        if events.empty?
          puts "No events in this time range."
          return
        end

        display_events = events.select do |event|
          !ca.config.setting(CalendarAssistant::Config::Keys::Options::COMMITMENTS) || event.commitment?
        end

        printed_now = false
        display_events.each do |event|
          printed_now = print_now! ca, event, printed_now
          puts event_description(event)
          pp event if ca.config.debug?
        end

        puts
      end

      def print_available_blocks ca, event_set, omit_title: false
        ers = ca.config.attendees.map {|calendar_id| ca.event_repository calendar_id}
        time_zones = ers.map {|er| er.calendar.time_zone}.uniq

        unless omit_title
          puts Rainbow(ers.map {|er| er.calendar.id}.join(", ")).italic
          puts Rainbow(sprintf("- looking for blocks at least %s long",
                               ChronicDuration.output(
                                   ChronicDuration.parse(
                                       ca.config.setting(Config::Keys::Settings::MEETING_LENGTH))))).italic
          time_zones.each do |time_zone|
            puts Rainbow(sprintf("- between %s and %s in %s",
                                 ca.config.setting(Config::Keys::Settings::START_OF_DAY),
                                 ca.config.setting(Config::Keys::Settings::END_OF_DAY),
                                 time_zone,
                         )).italic
          end
          puts
        end

        if event_set.is_a?(EventSet::Hash)
          event_set.events.each do |key, value|
            puts(sprintf(Rainbow("Availability on %s:\n").bold,
                         key.strftime("%A, %B %-d")))
            print_available_blocks ca, event_set.new(value), omit_title: true
            puts
          end
          return
        end

        events = Array(event_set.events)
        if events.empty?
          puts "  (No available blocks in this time range.)"
          return
        end

        events.each do |event|
          line = []
          time_zones.each do |time_zone|
            line << sprintf("%s - %s",
                            event.start_time.in_time_zone(time_zone).strftime("%l:%M%P"),
                            event.end_time.in_time_zone(time_zone).strftime("%l:%M%P %Z"))
          end
          line.uniq!
          puts " • " + line.join(" / ") + Rainbow(" (" + event.duration + ")").italic
          pp event if ca.config.debug?
        end
      end

      def event_description event
        s = sprintf("%-25.25s", event_date_description(event))

        date_ansi_codes = []
        date_ansi_codes << :bright if event.current?
        date_ansi_codes << :faint if event.past?
        s = date_ansi_codes.inject(Rainbow(s)) {|text, ansi| text.send ansi}

        s += Rainbow(sprintf(" | %s", event.view_summary)).bold

        attributes = []
        unless event.private?
          attributes << "recurring" if event.recurring?
          attributes << "not-busy" unless event.busy?
          attributes << "self" if event.self? && !event.private?
          attributes << "1:1" if event.one_on_one?
          attributes << "awaiting" if event.awaiting?
          attributes << "tentative" if event.tentative?
          attributes << Rainbow(sprintf(" %s abandoned %s ", EMOJI_WARN, EMOJI_WARN)).red.bold.inverse if event.abandoned?
        end

        attributes << event.visibility if event.explicitly_visible?

        s += Rainbow(sprintf(" (%s)", attributes.to_a.sort.join(", "))).italic unless attributes.empty?

        s = Rainbow(Rainbow.uncolor(s)).faint.strike if event.declined?

        s
      end

      def event_date_description event
        if event.all_day?
          start_date = event.start_date
          end_date = event.end_date
          if (end_date - start_date) <= 1
            event.start.to_s
          else
            sprintf("%s - %s", start_date, end_date - 1.day)
          end
        else
          if event.start_date == event.end_date
            sprintf("%s - %s", event.start.date_time.strftime("%Y-%m-%d  %H:%M"), event.end.date_time.strftime("%H:%M"))
          else
            sprintf("%s  -  %s", event.start.date_time.strftime("%Y-%m-%d %H:%M"), event.end.date_time.strftime("%Y-%m-%d %H:%M"))
          end
        end
      end
    end
  end
end