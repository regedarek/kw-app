import React from 'react';
import Spinner from "../spinner";
import { EditorState, ContentState, convertFromHTML } from 'draft-js';
import { Editor } from "react-draft-wysiwyg";
import FileUploader from "../fileUploader";

import {
    withRouter
} from "react-router-dom";
import ShopContext from "./shopContext";

class ShopItemContainer extends React.Component {
    static contextType = ShopContext;

    constructor(props) {
        super(props);
        this.state = {
            isLoading: true,
            editorState: EditorState.createEmpty()
        }
    }

    componentDidMount() {
        const id = this.props.match.params.id;
        let request = null;
        if (id) {
            request = window.fetch(`/api/items/${id}`)
        } else {
            request = window.fetch('/api/items', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    item: {
                        name: "Nowy przedmiot",
                        description: "Opis",
                        price: "9999",
                        item_kinds_attributes: []
                    }
                })
            })
        }
        request
        .then(response => response.json())
        .then(data => {
            this.setState({
                data: {
                    description: "",
                    price: "",
                    name: "",
                    ...data
                },
                isLoading: false,
                editorState: EditorState.createWithContent(
                    ContentState.createFromBlockArray(
                        convertFromHTML(data.description)
                    )
                    ),                
            });
        });
    }

    onInputChange(property, value) {
        this.setState({
            data: {
                ...this.state.data,
                [property]: value
            }
        })
    }

    onEditorStateChange(editorState){
        this.setState({
            editorState,
        });
    }

    render() {
        const {isLoading, data, editorState} = this.state;
        if (isLoading) {
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
                                <input type="text" id="item_name" value={data.name} onChange={e => this.onInputChange("name", e.target.value)} />
                            </div>
                            <div className="large-4 columns">
                                <label htmlFor="item_price">
                                    Cena
                                </label>
                                <input type="text" id="item_price"  value={data.price} onChange={e => this.onInputChange("price", e.target.value)} />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div className="row">
                <div className="large-12 columns">
                    <div className="callout ">
                        Opis
                        <Editor
                            editorState={editorState}
                            onEditorStateChange={this.onEditorStateChange.bind(this)}
                        />
                    </div>
                </div>
            </div>
            <div className="row">
            <div className="large-12 columns">
                    <div className="callout ">
                        Stan
                        <select value={data.state} onChange={e => this.onInputChange("state", e.target.value)}>
                            <option value="draft">draft</option>
                            <option value="published">published</option>
                        </select>
                    </div>
                </div>
            </div>
            <div className="row">
                <div className="large-12 columns">
                    <FileUploader userId={this.context} uploadableId={this.state.data && this.state.data.id} uploadableType={"Shop::ItemRecord"} files={this.state.data && this.state.data.photos} />
                </div>
            </div>
        </>
    }
}

export default withRouter(ShopItemContainer);