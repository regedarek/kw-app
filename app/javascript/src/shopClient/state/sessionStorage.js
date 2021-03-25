export const loadState = () => {
    try {
      const serializedState = window.sessionStorage.getItem('state');
  
      if (serializedState === null) {
        return undefined;
      }
  
      return JSON.parse(serializedState);
    } catch (error) {
      return undefined;
    }
  };
  
  export const saveState = (state) => {
    try {
      const serializedState = JSON.stringify(state);
      window.sessionStorage.setItem('state', serializedState);
    } catch (error) {
      
    }
  };