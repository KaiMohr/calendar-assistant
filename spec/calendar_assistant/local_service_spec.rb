describe CalendarAssistant::LocalService do
  let(:service) { described_class.new }
  let(:calendar_id) { "calendar_id" }
  let(:event) { double(:event, id: "1", original: true) }
  let(:new_event) { double(:event, id: "2", original: false) }

  let(:location_event) { double(:location_event, id: 99, start: GCal::EventDateTime.new(date: Date.parse("2018-10-18")), end: GCal::EventDateTime.new(date: Date.parse("2018-10-19"))) }
  let(:nine_event) { double(:nine_event, id: 1, start: GCal::EventDateTime.new(date_time: Time.parse("2018-10-18 09:00:00")), end: GCal::EventDateTime.new(date_time: Time.parse("2018-10-18 10:00:00"))) }
  let(:nine_thirty_event) { double(:nine_thirty_event, id: 2, start: GCal::EventDateTime.new(date_time: Time.parse("2018-10-18 09:30:00")), end: GCal::EventDateTime.new(date_time: Time.parse("2018-10-18 10:00:00"))) }
  let(:next_day_event) { double(:next_day_event, id: 3, start: GCal::EventDateTime.new(date_time: Time.parse("2018-11-18 09:30:00")), end: GCal::EventDateTime.new(date_time: Time.parse("2018-11-18 10:00:00"))) }

  context "when no filename is passed" do

    describe "#list_events" do

      before do
        service.insert_event(calendar_id, location_event)
        service.insert_event(calendar_id, nine_event)
        service.insert_event(calendar_id, nine_thirty_event)
        service.insert_event(calendar_id, next_day_event)
      end

      it "returns events from the search day" do
        events = service.list_events(calendar_id, time_min: Time.parse("2018-10-18 08:00:00").iso8601, time_max: Time.parse("2018-10-18 18:00:00").iso8601)

        expect(events.items).to match_array(
                                    [
                                        location_event,
                                        nine_event,
                                        nine_thirty_event
                                    ]
                                )
      end
    end

    it "deletes an event" do
      service.insert_event(calendar_id, event)
      service.delete_event(calendar_id, event.id)
      expect(service.get_event(calendar_id, event.id)).not_to be
    end

    it "updates an event" do
      service.insert_event(calendar_id, event)
      service.update_event(calendar_id, event.id, new_event)
      expect(service.get_event(calendar_id, event.id)).to eq new_event
    end
  end

  context "when a filename is passed" do
    include FakeFS::SpecHelpers

    let(:filename) { "a_file_to_remember" }
    let(:service) { described_class.new(file: filename, load_events: load_events) }

    before do
      File.open(filename, "w") { |f| f.write({calendar_id => {events: { 5678 => GCal::Event.new(id: 5678)}}}.to_yaml) }
    end

    context "and we want to load events" do
      let(:load_events) { true }

      it "finds the event from disk" do
        expect(service.get_event(calendar_id, 5678).id).to eq(5678)
      end

      it "saves events to disk" do
        expect(service.get_event(calendar_id, nine_event.id)).not_to be

        service.insert_event(calendar_id, nine_event)
        service.insert_event(calendar_id, nine_thirty_event)

        service.delete_event(calendar_id, nine_thirty_event.id)

        service.update_event(calendar_id, nine_event.id, GCal::Event.new(id: nine_event.id, summary: "funkadelic"))

        new_service = described_class.new(file: filename)
        expect(new_service.get_event(calendar_id, nine_event.id)).to be
        expect(new_service.get_event(calendar_id, nine_event.id).summary).to eq "funkadelic"
      end
    end

    context "and we don't want to load events" do
      let(:load_events) { false }

      it "does not find the event from disk" do
        expect(service.get_event(calendar_id, 5678)).not_to be
      end

      it "saves only created events to disk" do
        expect(service.get_event(calendar_id, nine_event.id)).not_to be
        service.insert_event(calendar_id, nine_event)

        new_service = described_class.new(file: filename)
        expect(new_service.get_event(calendar_id, nine_event.id)).to be
        expect(new_service.get_event(calendar_id, 5678)).not_to be
      end
    end
  end
end
