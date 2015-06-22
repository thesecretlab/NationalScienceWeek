package au.net.scienceweek.scienceweek.network;

import java.util.List;

import retrofit.Callback;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.Response;
import retrofit.converter.SimpleXMLConverter;

public class EventServiceFactory {
    private static List<Event> events;

    public static List<Event> getEvents() {
        return events;
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
                cb.success(events.events, response);
            }

            @Override
            public void failure(RetrofitError error) {
                cb.failure(error);
            }
        });
    }


}
