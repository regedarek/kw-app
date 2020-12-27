import React from 'react';
import CalendarIconComponent from "./calendarIconComponent";

function EventsCalendarContainer({events}) {
    return (
        <div style={{
            display: "flex",
            flexDirection: "column"
        }}>
            {(events || []).slice(0, 3).map(event => {
                return (
                    <div key={event.id} style={{
                        display: "flex",
                        alignItems: "center",
                        padding: "15px"
                    }}>
                        <CalendarIconComponent date={event.start_date} />
                        <div style={{
                            paddingLeft: "5px"
                        }}>
                            {event.name}
                        </div>
                    </div>
                )
            })}
        </div>
    )
}
export default EventsCalendarContainer;