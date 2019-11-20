import React from 'react';

const universityForm = (props) => {
    return (
        <div>
            <h1>Welcome to {props.name}</h1>
            <h2>URL: {props.url}</h2>
            <h1>Create University!</h1>            
            University Name: <input></input>
            Description: <textarea></textarea>
            Website: <text></text>
            Phone Number: <textbox></textbox>
        </div>    
    )
};

export default universityForm;