import React from 'react';

function compareTotals(a, b) {
    if (!a) {
        return 1;
    }
    if (!b) {
        return -1;
    }

    return b.total_length - a.total_length;
 }

function NarciarskieDziki({ data }) {
    const sortedData = (data || []).sort(compareTotals)
    return (
        <>
            <thead>
                <tr>
                    <th width='30px'>Miejsce</th>
                    <th width='25px'>Miejsce</th>
                    <th width='250px'>Kto?</th>
                    <th className="large-text-left">Ostatnie przejście</th>
                    <th className="large-text-right" width='120px'>Kontrakty</th>
                    <th className="large-text-right" width='120px'>Metry</th>
                    <th className="large-text-right" width='120px'>Suma</th>
                </tr>
            </thead>
            <tbody>
                {sortedData.map((dzik, id) => {
                        const displayObj = {
                            avatar: "",
                            displayName: "",
                            trainingContractsLength: 0,
                            totalMountainRoutesLength: 0,
                            totalLength: 0,
                            last_activity: {},
                        }
                        if (dzik && dzik.leader) {
                            displayObj.avatar = dzik.leader.avatar && dzik.leader.avatar.url;
                            displayObj.displayName = dzik.leader.display_name;
                        }
                        if (dzik) {
                            displayObj.trainingContractsLength = dzik.training_contracts_length;
                            displayObj.totalMountainRoutesLength = dzik.total_mountain_routes_length;
                            displayObj.totalLength = dzik.total_length;
                            displayObj.last_activity = dzik.last_activity;
                        }
                        return (
                            <tr key={id}>
                                <td className="text-center">{id+1}</td>
                                <td width='45px'>
                                    <img src={displayObj.avatar} />
                                </td>
                                <td className="text-center large-text-left">{displayObj.displayName}</td>
                                <td className="large-text-left">
                                    <a href={"/przejscia/" + displayObj.last_activity.id}>
                                        {displayObj.last_activity.name}
                                    </a>
                                </td>
                                <td className="text-center large-text-right">{displayObj.trainingContractsLength}</td>
                                <td className="text-center large-text-right">{displayObj.totalMountainRoutesLength}</td>
                                <td className="text-center large-text-right">{displayObj.totalLength}</td>
                            </tr>
                        )
                    })}
            </tbody>
        </>
    )
}
export default NarciarskieDziki;