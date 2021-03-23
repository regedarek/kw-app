import React from 'react';

function FileUploader({ maxSize, onFileChange }) {
    return (
        <div style={{position: "relative"}}>
            <label className="button large" htmlFor="file-upload">
                Kliknij, lub upuść plik tutaj
            </label>
            <input type="file" accept="image/*" id="file-upload"
                style={{position: "absolute", top: 0, left: 0, right: 0, bottom: 0, visibility: "hidden"}}
                onChange={onFileChange}
                />
            <div>Dozwolony rozmiar: {maxSize/1024/1024} MB</div>
        </div>
    )
}
export default FileUploader;