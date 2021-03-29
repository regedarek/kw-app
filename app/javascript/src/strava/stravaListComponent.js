import React from 'react';

function StravaList({items, onImport, onImportSelected, onSelect, onSelectAll, allSelected, selectCount}){
    return (
        <>
            {items && items.length === 0 && (
                <div className="row">
                    <div className="columns large-12">
                        Brak odpowiednich aktywności (BackcountrySki, NordicSki, RockClimbing)                    
                        <br/>
                        <a href='/przejscia#my_strava_routes'>Przejdź do zaimportowanych przejść</a>
                    </div>
                </div>
            )}
            {items && items.length > 0 &&
                <div className="row">
                    <div className="columns large-12">
                        <table>
                            <thead>
                                <tr>
                                    <th colSpan="2" className="text-left">
                                        <input type="checkbox" onChange={(event) => onSelectAll(event)}
                                            checked={allSelected}
                                            className="margin-none"
                                        /> Zaznacz wszystko
                                    </th>
                                    <th width="150px" className="text-center">
                                      Typ
                                    </th>
                                    <th width="120px" className="text-center">
                                      Do góry
                                    </th>
                                    <th width="120px" className="text-center">
                                      Dystans
                                    </th>
                                    <th width="120px" className="text-center">
                                      Czas
                                    </th>
                                    <th width="120px" className="text-center">
                                      Kiedy?
                                    </th>
                                    <th width="150px" className="text-center">
                                        <button className="button success margin-none" onClick={() => onImportSelected()}
                                        disabled={selectCount < 1}>
                                            Zaimportuj zaznaczone ({selectCount})
                                        </button>
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                {items && items.map(el => 
                                    <tr key={el.id}>
                                        <td width="40px">
                                            <input type="checkbox" 
                                                checked={el.checked}
                                                onChange={() => onSelect(el.id)}
                                                className="margin-none"
                                            />
                                        </td>
                                        <td className="text-left">
                                            <a href={el.strava_url}>
                                                {el.name}
                                            </a>
                                        </td>
                                        <td className="text-center">
                                          {el.route_type}
                                        </td>
                                        <td className="text-center">
                                          {el.length} m
                                        </td>
                                        <td className="text-center">
                                          {el.distance} km
                                        </td>
                                        <td className="text-center">
                                          {el.time}
                                        </td>
                                        <td className="text-center">
                                          {el.start_date}
                                        </td>
                                        <td className="text-center">
                                            <button className="button margin-none" onClick={() => { onImport(el.id) }}>Zaimportuj</button>
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            }
        </>
    )

}

export default StravaList;
