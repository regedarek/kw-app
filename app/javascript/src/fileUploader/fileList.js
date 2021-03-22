import React from 'react';

function FileEntity({data, onFileRemove}) {
    const f = data.file;
    return  <div className="row" style={{display: "flex", alignItems: "center"}}>
                <div className="columns small-1">
                    {f && f.thumb && <img src={f.thumb.url} />}
                </div>
                <div className="columns small-10">
                    {data.name}
                </div>
                <div className="columns small-1">
                    <button className="button alert" onClick={() => onFileRemove(data.id)}>Usuń</button>
                </div>
            </div>
}

function FileList({ files, onFileRemove }) {
    return (
        <div>
            {files && files.map(f => (
                <FileEntity data={f} key={f.id} onFileRemove={onFileRemove}/>
            ))}
        </div>
    )
}

export default FileList;