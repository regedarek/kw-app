import React from 'react';

function NarciarskieDzikiSmall({ data, keyPrefix }) {
    return (
        <table className="stack">
            <thead>
                <tr>
                    <th></th>
                    <th>Kto?</th>
                    <th width='15%'>metrów</th>
                </tr>
            </thead>
            <tbody>
                {data.slice(0, 5).map((dzik, id) => {
                        return (
                            <tr key={keyPrefix + id}>
                                <td width='45px'>
                                    <img src={dzik.avatar} />
                                </td>
                                <td className="text-center large-text-left">{dzik.displayName}</td>
                                <td className="text-center">{dzik.totalMountainRoutesLength}</td>
                            </tr>
                        )
                    })}
            </tbody>
        </table>
    )
}
export default NarciarskieDzikiSmall;