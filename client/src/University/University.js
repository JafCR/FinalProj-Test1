import React from 'react';

const university = (props) => {
    return (
        <div>
            <h1>Welcome to {props.name}</h1>
            <h2>URL: {props.url}</h2>            
        </div>    
    )
};

export default university;