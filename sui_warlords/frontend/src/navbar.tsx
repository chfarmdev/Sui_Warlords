import React from "react";
import { Link } ReactDOM from "react-dom/client";
import "@mysten/dapp-kit/dist/index.css";
import "@radix-ui/themes/styles.css";

const navbar= () =>{
    return (
    <div>
      <li>
        <Link to="/">Dogs</Link>
      </li>
      <li>
        <Link to="/cats">Cats</Link>
      </li>
      <li>
        <Link to="/sheeps">Sheeps</Link>
      </li>
      <li>
        <Link to="/goats">Goats</Link>
      </li>
    </div>
    );
  }
  export default navbar;