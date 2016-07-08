package au.net.scienceweek.scienceweek;

import android.content.Intent;
import android.net.Uri;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.text.SimpleDateFormat;

import au.net.scienceweek.scienceweek.network.Event;
import au.net.scienceweek.scienceweek.network.EventServiceFactory;


public class EventDetailActivity extends ActionBarActivity {

    final static String EXTRA_EVENT_ID = "eventID";

    private Event e;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_event_detail);

        e = EventServiceFactory.findEvent(getIntent().getStringExtra(EXTRA_EVENT_ID));

        if (e != null) {

            setTextOrHide(R.id.eventDescriptionLabel, e.EventDescription);
            setTextOrHide(R.id.eventAudienceLabel, e.EventTargetAudience);


            setTextOrHide(R.id.eventDateLabel, e.getStartToFinishString());

            if (e.EventIsFree == true) {
                setTextOrHide(R.id.eventPriceLabel, "Free");
            } else {
                setTextOrHide(R.id.eventPriceLabel, e.EventPayment);
            }

            setTextOrHide(R.id.eventContactNameLabel, e.EventContactName);
            setTextOrHide(R.id.eventContactOrganisationLabel, e.EventContactOrganisation);
            setTextOrHide(R.id.eventContactEmailAddressLabel, e.EventContactEmail);
            setTextOrHide(R.id.eventContactPhoneNumberLabel, e.EventContactTelephone);


            if (e.Venue == null) {
                findViewById(R.id.eventVenueName).setVisibility(View.GONE);
                findViewById(R.id.eventVenueStreetName).setVisibility(View.GONE);
                findViewById(R.id.eventVenueSuburb).setVisibility(View.GONE);
                findViewById(R.id.eventVenuePostCode).setVisibility(View.GONE);

            } else {
                setTextOrHide(R.id.eventVenueName, e.Venue.VenueName);
                setTextOrHide(R.id.eventVenueStreetName, e.Venue.VenueStreetName);
                setTextOrHide(R.id.eventVenueSuburb, e.Venue.VenueSuburb);
                setTextOrHide(R.id.eventVenuePostCode, e.Venue.VenuePostcode);

            }

            setTextOrHide(R.id.eventVenueMoreInfo, e.EventMoreInfo);

            if (e.EventWebsite != null) {
                findViewById(R.id.eventMoreInfoButton).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Uri uri = Uri.parse(e.EventWebsite.toString());
                        Intent i = new Intent(Intent.ACTION_VIEW);
                        i.setData(uri);

                        startActivity(i);
                    }
                });
            } else {
                findViewById(R.id.eventMoreInfoButton).setVisibility(View.GONE);
            }

            if (e.Venue.VenueLatitude != 0 && e.Venue.VenueLongitude!= 0) {
                findViewById(R.id.eventShowMapButton).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        String geoUri = "geo:"+e.Venue.VenueLatitude+","+e.Venue.VenueLatitude;
                        Uri uri = Uri.parse(geoUri);
                        Intent i = new Intent(Intent.ACTION_VIEW);
                        i.setData(uri);

                        startActivity(i);
                    }
                });
            }

            getSupportActionBar().setTitle(e.EventName);
        }
    }

    private void setTextOrHide(int id, String label) {
        TextView t = (TextView) findViewById(id);

        if (TextUtils.isEmpty(label)) {
            t.setVisibility(View.GONE);
        } else {
            t.setText(label);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_event_detail, menu);


        MenuItem menuItem = menu.findItem(R.id.action_fav);

        updateFavouriteItemIcon(menuItem, Favourites.isEventFavourite(getApplicationContext(), e.EventID));

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == R.id.action_fav) {

            boolean isFavourite = Favourites.isEventFavourite(getApplicationContext(), e.EventID);

            boolean newFavourite = !isFavourite;

            Favourites.setEventFavourite(getApplicationContext(), e.EventID, newFavourite);

            updateFavouriteItemIcon(item, newFavourite);
        }


        return super.onOptionsItemSelected(item);
    }

    private void updateFavouriteItemIcon(MenuItem favouriteItem, boolean isFavourite) {
        if (isFavourite) {
            favouriteItem.setIcon(R.drawable.ic_action_favourite_active);
        } else {
            favouriteItem.setIcon(R.drawable.ic_action_favourite_inactive);
        }
    }


}
