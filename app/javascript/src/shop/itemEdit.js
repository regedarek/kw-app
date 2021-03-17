import React from 'react';
import Spinner from "../spinner";
import { Editor } from "react-draft-wysiwyg";
import FileUploader from "../fileUploader";

import {
    withRouter
} from "react-router-dom";

class ShopItemContainer extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            isLoading: true
        }
    }

    componentDidMount() {
        const id = this.props.match.params.id;
        if (id) {
            window.fetch('/api/items')
            .then(response => response.json())
            .then(data => {
                this.setState({
                    data: data.find(el => el.id == id),
                    isLoading: false
                });
            });
        } else {
            window.fetch('/api/items', {
                method: 'POST',
                body: JSON.stringify({
                    item: {}
                })
            })
            .then(response => response.json())
            .then(data => {
                this.setState({
                    data: data.find(el => el.id == id),
                    isLoading: false
                });
            });
        }
    }

    render() {
        if (this.state.isLoading) {
            return <Spinner></Spinner>
        }
        return <>
            <div className="row">
                <div className="large-12 columns">
                    <div className="callout primary">
                        <div className="row">
                            <div className="large-4 columns">
                                <label htmlFor="item_name">
                                    Nazwa
                                </label>
                                <input type="text" id="item_name" />
                            </div>
                            <div className="large-4 columns">
                                <label htmlFor="item_name">
                                    Cena
                                </label>
                                <input type="text" id="item_name" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div className="row">
                <div className="large-12 columns">
                    <div className="callout ">
                        Opis
                        <Editor />
                    </div>
                </div>
            </div>
            <div className="row">
                <div className="large-12 columns">
                    <FileUploader />
                </div>
            </div>
        </>
    }
}

export default withRouter(ShopItemContainer);