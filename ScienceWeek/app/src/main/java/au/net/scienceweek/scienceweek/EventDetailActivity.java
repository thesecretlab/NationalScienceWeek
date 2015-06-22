package au.net.scienceweek.scienceweek;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

import au.net.scienceweek.scienceweek.network.Event;
import au.net.scienceweek.scienceweek.network.EventServiceFactory;


public class EventDetailActivity extends ActionBarActivity {

    final static String EXTRA_EVENT_ID = "eventID";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_event_detail);

        Event e = EventServiceFactory.findEvent(getIntent().getStringExtra(EXTRA_EVENT_ID));

        if (e != null) {
            TextView desc = (TextView) findViewById(R.id.eventDescriptionLabel);
            desc.setText(e.EventDescription);

            getSupportActionBar().setTitle(e.EventName);
        }



    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_event_detail, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
