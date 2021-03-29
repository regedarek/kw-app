import React from 'react';

function StravaList({items, onImport, onImportSelected, onSelect, onSelectAll, allSelected}){
    return (
        <>
            {items && items.length === 0 && (
                <div className="row">
                    <div className="columns large-12">
                        Brak odpowiednich aktywności (BackcountrySki, NordicSki, RockClimbing)                    
                    </div>
                </div>
            )}
            {items && items.length > 0 &&
                <div className="row">
                    <div className="columns large-12">
                        <table>
                            <thead>
                                <tr>
                                    <th colSpan="2">
                                        <input type="checkbox" onChange={(event) => onSelectAll(event)}
                                            checked={allSelected}
                                        /> Zaznacz wszystko
                                    </th>
                                    <th width="25%" className="text-center">
                                        <button className="button" onClick={() => onImportSelected()}>
                                            Zaimportuj zaznaczone
                                        </button>
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                {items && items.map(el => 
                                    <tr key={el.id}>
                                        <td width="5%">
                                            <input type="checkbox" 
                                                checked={el.checked}
                                                onChange={() => onSelect(el.id)}
                                            />
                                        </td>
                                        <td width="70%" >
                                            <a href={el.strava_url}>
                                                {el.name}
                                            </a>
                                        </td>
                                        <td className="text-center" width="25%">
                                            <button className="button" onClick={() => { onImport(el.id) }}>Import</button>
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