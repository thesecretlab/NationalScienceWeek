package au.net.scienceweek.scienceweek;

import android.app.ProgressDialog;
import android.content.Intent;
import android.net.Uri;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import java.util.Date;
import java.util.List;

import au.net.scienceweek.scienceweek.network.Event;
import au.net.scienceweek.scienceweek.network.EventServiceFactory;
import retrofit.Callback;
import retrofit.RetrofitError;
import retrofit.client.Response;


public class MainActivity extends ActionBarActivity implements ActionBar.OnNavigationListener {

    private String[] getStateNames() {
        String[] states = getResources().getStringArray(R.array.state_list);
        return states;
    }

    private String[] getStateDisplayNames() {
        String[] states = getResources().getStringArray(R.array.pretty_state_list);
        return states;
    }

    ArrayAdapter<Event> eventArrayAdapter;


    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        final ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayShowTitleEnabled(false);
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_LIST);

        setContentView(R.layout.activity_main);


        findViewById(R.id.eventListProgressBar).setVisibility(View.VISIBLE);

        EventServiceFactory.loadEvents(this, new Callback<List<Event>>() {
            @Override
            public void success(List<Event> events, Response response) {
                ListView listView = (ListView) findViewById(R.id.eventListView);

                eventArrayAdapter = new EventListAdapter(MainActivity.this, events);
                eventArrayAdapter.setNotifyOnChange(true);

                String selectedState = getStateNames()[getSupportActionBar().getSelectedNavigationIndex()];
                showEvents(selectedState);

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

                findViewById(R.id.eventListProgressBar).setVisibility(View.GONE);


                supportInvalidateOptionsMenu();
            }

            @Override
            public void failure(RetrofitError error) {
                findViewById(R.id.eventListProgressBar).setVisibility(View.GONE);
                Toast.makeText(getApplicationContext(), "Error loading events!", Toast.LENGTH_SHORT).show();
            }


        });



        // Set up the dropdown list navigation in the action bar.
        actionBar.setListNavigationCallbacks(
                // Specify a SpinnerAdapter to populate the dropdown list.
                new ArrayAdapter<String>(
                        actionBar.getThemedContext(),
                        android.R.layout.simple_list_item_1,
                        android.R.id.text1,
                        getStateDisplayNames()),
                this);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);

        boolean eventActionsVisible = EventServiceFactory.getEvents() != null &&
                EventServiceFactory.getEvents().size() > 0;

        // Hide items if we have no events
        menu.findItem(R.id.action_show_favourites).setVisible(eventActionsVisible);
        menu.findItem(R.id.action_show_map).setVisible(eventActionsVisible);
        menu.findItem(R.id.action_show_today).setVisible(eventActionsVisible);

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_about) {

            Intent intent = new Intent(getApplicationContext(), AboutActivity.class);

            startActivity(intent);



            return true;
        }

        if (id == R.id.action_show_favourites) {

            Intent intent = new Intent(getApplicationContext(), FavouritesListActivity.class);
            startActivity(intent);

        }

        if (id == R.id.action_show_map) {

            Intent intent = new Intent(getApplicationContext(), MapsActivity.class);
            startActivity(intent);

        }

        if (id == R.id.action_show_today) {

            // Find the next event



            Date now = new Date();

            if (eventArrayAdapter != null && eventArrayAdapter.getCount() > 0) {
                for (int i=0; i < eventArrayAdapter.getCount(); i++) {
                    Event e = eventArrayAdapter.getItem(i);

                    if (e.getStartDate().compareTo(now) > 0) {

                        ListView listView = (ListView) findViewById(R.id.eventListView);

                        listView.smoothScrollToPosition(i);

                        break;
                    }


                }
            }

        }

        return super.onOptionsItemSelected(item);
    }


    @Override
    public boolean onNavigationItemSelected(int itemPosition, long itemId) {
        String[] stateNames = getStateNames();

        String selectedState = stateNames[itemPosition];

        return showEvents(selectedState);

    }

    private boolean showEvents(String selectedState) {
        List<Event> events = EventServiceFactory.getEvents(selectedState);

        if (eventArrayAdapter != null) {
            eventArrayAdapter.clear();

            if (events.size() > 0) {
                eventArrayAdapter.addAll(events);
            }

            return true;
        }
        return false;
    }
}
