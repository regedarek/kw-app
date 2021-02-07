import React from 'react';
import CalendarIconComponent from "./calendarIconComponent";

function EventsCalendar({ events }) {
    return (
        <div>
            <div style={{
                display: "flex",
                flexDirection: "column"
            }}>
                {(events || []).slice(0, 3).map(event => {
                    return (
                        <a href={"supplementary/courses/" + event.id} key={event.id} className="list-element display-flex space-between">
                            <CalendarIconComponent date={event.start_date} />
                            <div className="event-name">
                                {event.name}
                            </div>
                            <div className="list-element-arrow">
                                &gt;
                            </div>
                        </a>
                    )
                })}
            </div>
            {events && events.length > 3 ? <a href="supplementary/courses" style={{float: "right"}}>Więcej</a> : <></>}
        </div>
    )
}
export default EventsCalendar;