package au.net.scienceweek.scienceweek.network;

import java.util.ArrayList;
import java.util.List;

import retrofit.Callback;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.Response;
import retrofit.converter.SimpleXMLConverter;

public class EventServiceFactory {
    private static List<Event> events;

    public static Event findEvent(String eventID) {
        for (int i = 0; i < events.size(); i++) {
            Event e = events.get(i);
            if (e.EventID.equals(eventID)) {
                return e;
            }
        }
        return null;
    }

    public static List<Event> getEvents() {
        return events;
    }

    public static List<Event> getEvents(String state) {
        if (events == null)
            return null;

        ArrayList<Event> eventsInState = new ArrayList<Event>();

        for (int i = 0; i < events.size(); i++) {
            Event e = events.get(i);
            if (e.EventState.equals(state)) {
                eventsInState.add(e);
            }
        }

        return eventsInState;
    }

    public static EventService createService() {
        RestAdapter restAdapter = new RestAdapter.Builder()
                .setEndpoint("http://www.scienceweek.net.au")
                .setConverter(new SimpleXMLConverter())
                .build();
        return restAdapter.create(EventService.class);
    }

    public static void loadEvents(final Callback<List<Event>> cb) {
        createService().getEvents(new Callback<Events>() {
            @Override
            public void success(Events events, Response response) {
                EventServiceFactory.events = events.events;
                cb.success(new ArrayList<Event>(events.events), response);
            }

            @Override
            public void failure(RetrofitError error) {
                cb.failure(error);
            }
        });
    }


}
