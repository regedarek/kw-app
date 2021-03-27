import React from 'react';

function StravaList({items, onImport}){
    return (
        <>
            {items && items.length === 0 && (
                <div className="row">
                    <div className="columns large-12">
                        Brak odpowiednich aktywności (BackcountrySki, NordicSki, RockClimbing)                    
                    </div>
                </div>
            )}
            {items && items.map(el => 
                <div className="row">
                    <div className="columns large-8">
                        <a href={el.strava_url}>
                            {el.name}
                        </a>
                    </div>
                    <div className="columns large-4">
                        <button className="button" onClick={() => { onImport(el.id) }}>Import</button>
                    </div>
                </div>
            )}
        </>
    )

}

export default StravaList;