package au.net.scienceweek.scienceweek.network;

import retrofit.Callback;
import retrofit.http.GET;

public interface EventService {
    @GET("/event-transfer/scienceweek-events.xml")
    void getEvents(Callback<Events> cb);
}
