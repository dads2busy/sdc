

import React from 'react';
import ReactSlider from "react-slider";
import PropTypes from 'prop-types';
import { Tooltip } from "react-tooltip";
import 'react-tooltip/dist/react-tooltip.css';

const Slider = (props) => {
  const handleChange = (value) => {
    props.onChange(props.id, value);
  };

  const handleInputChange = (event) => {
    const value = event.target.value;
    props.onChange(props.id, value);
  };

  return (
    <div>
      <div className="container2">
        <h4 id={props.id} className="feature_Name">{props.feature}</h4>
        <Tooltip
          anchorSelect={`#${props.id}`}
          content={props.text}
        />
        <div className="container">
          <ReactSlider
            className="customSlider"
            trackClassName="customSlider-track"
            thumbClassName="customSlider-thumb"
            // markClassName="customSlider-mark"
            min={parseFloat(props.min)}
            max={parseFloat(props.max)}
            marks={20}
            // defaultValue={80}
            value={props.value}
            onChange={handleChange}
            step={0.01} 
            renderMark={(props) => {
              if (props.key < props.value) {
                props.className = "customSlider-mark customSlider-mark-before";
              } else if (props.key === props.value) {
                props.className = "customSlider-mark customSlider-mark-active";
              }
              return <span {...props} />;
            }}
          />
          <input
            type="number"
            className="textbox"
            value={props.value}
            onChange={handleInputChange}
          />
        </div>
      </div>
    </div>
  );
}

Slider.propTypes = {
  feature: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onChange: PropTypes.func.isRequired,
};

export default Slider;


