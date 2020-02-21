// This file is released under the terms of the MIT License.
// Please see LICENSE.md in the root directory.

package au.net.scienceweek.scienceweek.network;

import retrofit.Callback;
import retrofit.http.GET;

public interface EventService {
    @GET("/event-transfer/scienceweek-events.xml")
    void getEvents(Callback<Events> cb);
}
