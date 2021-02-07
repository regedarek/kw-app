import React from 'react';

function NarciarskieDziki({ data, keyPrefix }) {
    return (
        <table className="stack">
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
                {data.map((dzik, id) => {
                        return (
                            <tr key={keyPrefix + id}>
                                <td className="text-center">{id+1}</td>
                                <td width='45px'>
                                    <img src={dzik.avatar} />
                                </td>
                                <td className="text-center large-text-left">{dzik.displayName}</td>
                                <td className="large-text-left">
                                    <a href={"/przejscia/" + dzik.last_activity.id}>
                                        <h6 className="dashboard-table-text">{dzik.last_activity.name}</h6>
                                        {dzik.last_activity.contracts &&
                                            <span className="dashboard-table-timestamp-small">
                                                {dzik.last_activity.contracts}
                                            </span>
                                        }
                                    </a>
                                </td>
                                <td className="text-center large-text-right">{dzik.trainingContractsLength}</td>
                                <td className="text-center large-text-right">{dzik.totalMountainRoutesLength}</td>
                                <td className="text-center large-text-right">{dzik.totalLength}</td>
                            </tr>
                        )
                    })}
            </tbody>
        </table>
    )
}
export default NarciarskieDziki;