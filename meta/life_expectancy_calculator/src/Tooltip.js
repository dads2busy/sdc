import React from "react";
import ReactTooltip from 'react-tooltip';

const Tooltip = ({ id, text, tooltipText }) => {
    return (<>
        <span data-tip={tooltipText} data-for={id}>{text}</span>
        <ReactTooltip id={id} effect="solid" />
        </>);
}

export default Tooltip;