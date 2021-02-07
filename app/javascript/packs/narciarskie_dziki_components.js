import React from 'react';
import ReactDOM from 'react-dom';
import NarciarskieDzikiComponent from "../src/narciarskieDzikiContainer";

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <NarciarskieDzikiComponent type="season" isSmall={false} />,
      document.getElementById("narciarskie_dziki_component"),
    )
    ReactDOM.render(
      <NarciarskieDzikiComponent type="winter" isSmall={true} />,
      document.getElementById("narciarskie_dziki_component_winter"),
    )
    ReactDOM.render(
      <NarciarskieDzikiComponent type="spring" isSmall={true} />,
      document.getElementById("narciarskie_dziki_component_spring"),
    )
  })
  