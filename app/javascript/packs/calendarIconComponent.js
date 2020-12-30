import React from 'react';

function CalendarIconComponent({date}) {
    const parsedDate = new Date(date);
    let month = parsedDate.toLocaleString('default', { month: 'long' });
    let day = parsedDate.getDate();

    return (
        <div title={date} className="calendar-date-icon">
            <div className="calendar-date-icon-month">
                {month}
            </div>
            <div className="calendar-date-icon-day">
                {day}
            </div>
        </div>
    )
}
export default CalendarIconComponent;