package au.net.scienceweek.scienceweek.network;

import android.content.Context;
import android.util.Log;

import com.squareup.okhttp.Cache;
import com.squareup.okhttp.OkHttpClient;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.TimeUnit;

import au.net.scienceweek.scienceweek.Favourites;
import retrofit.Callback;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.OkClient;
import retrofit.client.Response;
import retrofit.converter.SimpleXMLConverter;
import retrofit.mime.TypedInput;

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

    public static List<Event> getFavourites(Context context) {
        ArrayList<Event> favouriteEvents = new ArrayList<Event>();

        for (int i = 0; i < events.size(); i++) {
            Event e = events.get(i);
            if (Favourites.isEventFavourite(context, e.EventID)) {
                favouriteEvents.add(e);
            }
        }

        return favouriteEvents;
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



        Collections.sort(eventsInState, new Comparator<Event>() {
            @Override
            public int compare(Event event, Event t1) {
                return event.getStartDate().compareTo(t1.getStartDate());
            }
        });

        return eventsInState;
    }

    public static EventService createService(Context context) {

        final int SIZE_OF_CACHE = 256 * 1024 * 1024; // 256KB

        OkHttpClient ok = new OkHttpClient();
        try {
            Cache responseCache = new Cache(context.getCacheDir(), SIZE_OF_CACHE);
            ok.setCache(responseCache);
        } catch (Exception e) {
            Log.d("EventServiceFactory", "Unable to set http cache", e);
        }

        ok.setReadTimeout(30, TimeUnit.SECONDS);
        ok.setConnectTimeout(30, TimeUnit.SECONDS);

        RestAdapter restAdapter = new RestAdapter.Builder()
                .setEndpoint("http://www.scienceweek.net.au")
                .setClient(new OkClient(ok))
                .setConverter(new SimpleXMLConverter())
                .setLogLevel(RestAdapter.LogLevel.HEADERS)
                .build();
        return restAdapter.create(EventService.class);

    }

    public static void loadEvents(Context context, final Callback<List<Event>> cb) {

        createService(context).getEvents(new Callback<Events>() {
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
