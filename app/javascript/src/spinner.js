import React from 'react';

export default function Spinner({centered}) {
    return (
        <div className={`mountains-spinner-wrapper ${centered ? "mountains-spinner-wrapper--centered" : ""}`} >
            <div className="mountains-spinner">
                <i className="fi fi-mountains"></i>
            </div>
        </div>
    )
}

