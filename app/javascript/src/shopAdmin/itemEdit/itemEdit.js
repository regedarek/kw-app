import React from 'react';
import Spinner from "../../spinner";
import { EditorState, ContentState, convertFromHTML } from 'draft-js';
import { Editor } from "react-draft-wysiwyg";
import FileUploader from "../../fileUploader";

import {
    withRouter
} from "react-router-dom";
import ShopContext from "../shopContext";

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
                        item_kinds: []
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
                    item_kinds: {
                        name: "",
                        quantity: 0
                    },
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

    saveChanges() {
        const {data} = this.state;
        this.setState({
            isLoading: true
        });
        console.log(data)
        window.fetch(`/api/items/${data.id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                item: {
                    name: data.name,
                    description: data.description,
                    price: data.price,
                    item_kinds_attributes: data.item_kinds
                }
            })
        })
        .then(response => response.json())
        .then(data => {
            this.setState({
                data: {
                    description: "",
                    price: "",
                    name: "",
                    item_kinds: [],
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
    
    onItemKindsChange(property, idx, value) {
        const {data} = this.state;
        const {item_kinds} = data;
        const newItemKinds =  [
            ...item_kinds.slice(0, idx),
            {
                ...item_kinds[idx],
                [property]: value
            },
            ...item_kinds.slice(idx+1)
        ]           
        this.setState({
            data: {
                ...data,
                item_kinds: newItemKinds
            }
        })
    }

    onEditorStateChange(editorState){
        this.setState({
            editorState,
        });
    }

    addItemAttributes() {
        const {data} = this.state;
        const {item_kinds} = data;
        this.setState({
            data: {
                ...data,
                item_kinds: [
                    ...item_kinds,
                    {
                        "quantity": 0,
                        "name": ""
                    }
                ]
            }
        })
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
                    <div className="callout">
                        Opis
                        <Editor
                            editorState={editorState}
                            onEditorStateChange={this.onEditorStateChange.bind(this)}
                            toolbar={{
                                inline: { inDropdown: true },
                                list: { inDropdown: true },
                                textAlign: { inDropdown: true },
                                link: { inDropdown: true },
                                history: { inDropdown: true },
                              }}
                        />
                    </div>
                </div>
            </div>
            <div className="row">
                <div className="large-12 columns">
                    <div className="callout ">
                        <div className="row">
                            <div className="columns large-12">

                            </div>
                        </div>
                        {data && data.item_kinds && data.item_kinds.map((el, idx) => {
                            return (
                                <div className="row" key={idx}>
                                    <div className="large-6 columns">
                                        <input type="text" value={el.name} onChange={e => this.onItemKindsChange("name", idx, e.target.value)}/>
                                    </div>
                                    <div className="large-6 columns">
                                        <input type="number" value={el.quantity} onChange={e => this.onItemKindsChange("quantity", idx, e.target.value)}/>
                                    </div>
                                </div>
                            )
                        })}
                        <div className="button succes" onClick={() => this.addItemAttributes()}>Dodaj</div>
                    </div>
                </div>
            </div>
            <div className="row">
                <div className="large-12 columns">
                    <div className="callout ">
                        Stan
                        <select value={data.state} onChange={e => this.onInputChange("state", e.target.value)}>
                            <option value="draft">Szkic (nieopublikowane)</option>
                            <option value="published">Opublikowane</option>
                        </select>
                    </div>
                </div>
            </div>
            <div className="row">
                <div className="large-12 columns text-right">
                    <div className="button info" onClick={this.saveChanges.bind(this)}>
                        Zapisz zmiany
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