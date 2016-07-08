package au.net.scienceweek.scienceweek.network;

import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;

import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

@Root(strict = false)
public class Event {

    @Override
    public String toString() {
        return EventName;
    }

    @Element(required = false)
	public String EventID;

    @Element(required = false)
	public String EventName;

    @Element(required = false)
	String EventType;

    /*@ElementList(inline=true)
    List<String> EventCategory;*/

    @Element(required = false)
    public String EventStart;

    final static String DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss";
    final static SimpleDateFormat DATE_FORMATTER = new SimpleDateFormat(DATE_FORMAT);

    public Date getStartDate() {
        try {
            return DATE_FORMATTER.parse(EventStart);
        } catch (ParseException e) {
            return null;
        }
    }

    public String getStartToFinishString() {
        try {
            Date startDate = DATE_FORMATTER.parse(EventStart);
            Date endDate = DATE_FORMATTER.parse(EventEnd);

            String startString = new SimpleDateFormat("dd LLL h:mm a").format(startDate);
            String endString = new SimpleDateFormat("h:mm a").format(endDate);


            String result = startString + " - " + endString;

            return result;

        } catch (ParseException e) {
            return null;
        }
    }

    @Element(required = false)
    public String EventEnd;

    @Element(required = false)
	public String EventDescription;

    @Element(required = false)
	public String EventTargetAudience;

    @Element(required = false)
	public String EventPayment;

    @Element(required = false)
	public boolean EventIsFree;

    @Element(required = false)
	public String EventContactName;

    @Element(required = false)
    public String EventContactOrganisation;

    @Element(required = false)
    public String EventContactTelephone;

    @Element(required = false)
    public String EventContactEmail;

    @Element(required = false)
    public URL EventWebsite;

    @Element(required = false)
	String EventState;

    @Element(required = false)
    public String EventMoreInfo;

    @Element(required = false)
    URL EventOfficialImageUrl;

    @Element(required=false)
    public Venue Venue;
  
}

