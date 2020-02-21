package au.net.scienceweek.scienceweek;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import java.util.List;

import au.net.scienceweek.scienceweek.network.Event;
import au.net.scienceweek.scienceweek.network.EventServiceFactory;


public class FavouritesListActivity extends ActionBarActivity {

    ArrayAdapter<Event> eventArrayAdapter;


    @Override
    protected void onResume() {
        super.onResume();

        List<Event> favourites = EventServiceFactory.getFavourites(getApplicationContext());
        ListView listView = (ListView) findViewById(R.id.favouritesListView);

        if (favourites.size() > 0) {


            listView.setVisibility(View.VISIBLE);
            findViewById(R.id.noFavouritesLabel).setVisibility(View.GONE);

            eventArrayAdapter = new EventListAdapter(this, favourites);
            eventArrayAdapter.setNotifyOnChange(true);

            listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                    Event e = (Event) adapterView.getItemAtPosition(i);

                    Intent intent = new Intent(getApplicationContext(), EventDetailActivity.class);
                    intent.putExtra(EventDetailActivity.EXTRA_EVENT_ID, e.EventID);
                    startActivity(intent);
                }
            });

            listView.setAdapter(eventArrayAdapter);
        } else {
            listView.setVisibility(View.GONE);
            findViewById(R.id.noFavouritesLabel).setVisibility(View.VISIBLE);
        }

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        final ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayShowTitleEnabled(true);

        setContentView(R.layout.activity_favourites_list);

    }


}
