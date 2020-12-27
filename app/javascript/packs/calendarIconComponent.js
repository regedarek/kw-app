import React from 'react';

function CalendarIconComponent({date}) {
    const parsedDate = new Date(date);
    let month = parsedDate.toLocaleString('default', { month: 'long' });
    let day = parsedDate.getDate();

    return (
        <div title={date} style={{
            width: "80px",
            textAlign: "center"
        }}>
            <div style={{
                color: "white",
                backgroundColor: "rgb(232, 86, 80)",
                width: "100%",
                borderTopLeftRadius: "15px",
                borderTopRightRadius: "15px"
            }}>
                {month}
            </div>
            <div style={{
                fontSize: "26px",
                borderBottomLeftRadius: "15px",
                borderBottomRightRadius: "15px",
                border: "1px solid #eee"
            }}>
                {day}
            </div>
        </div>
    )
}
export default CalendarIconComponent;