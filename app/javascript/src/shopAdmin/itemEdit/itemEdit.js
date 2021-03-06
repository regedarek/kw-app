import React from 'react';
import Spinner from "../../spinner";
import ReactQuill from 'react-quill';
import FileUploader from "../../fileUploader";
import { Link } from "react-router-dom";
import { ToastContainer, toast } from 'react-toastify';

import {
    withRouter
} from "react-router-dom";
import ShopContext from "../shopContext";

function decorateWithKey(data) {
    return (data || []).map(el => {
        return {
            ...el,
            key: Math.random()
        }
    })
}

class ShopItemContainer extends React.Component {
    static contextType = ShopContext;

    constructor(props) {
        super(props);
        this.state = {
            isLoading: true,
            activePanel: "panel-1"
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
                        description: "<p>Opis</p>",
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
                    ...data,
                    item_kinds: decorateWithKey(data.item_kinds)
                },
                isLoading: false
            });
        });
    }

    saveChanges() {
        const {data, editorState} = this.state;
        this.setState({
            isLoading: true
        });

        window.fetch(`/api/items/${data.id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                item: {
                    name: data.name,
                    description: data.description,
                    state: data.state,
                    item_kinds_attributes: data.item_kinds.map(el => {
                        const filteredObj = {
                            ...el
                        }
                        delete filteredObj['key'];
                        return filteredObj;
                    })
                }
            })
        })
        .then(response => response.json())
        .then(data => {
            this.setState({
                data: {
                    ...data,
                    item_kinds: decorateWithKey(data.item_kinds)
                },
                isLoading: false
            });

            toast.success("Zapisano", {
                position: toast.POSITION.BOTTOM_RIGHT
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

    onItemKindsChange(property, key, value) {
        if (property !== "name" && parseFloat(value) < 0) {
            value = 0;
        }

        const {data} = this.state;
        const {item_kinds} = data;
        const idx = item_kinds.findIndex(el => el.key === key);

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

    onEditorStateChange(editorState) {
        this.setState({
            editorState: editorState,
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
                        quantity: 0,
                        name: "",
                        price: 0.0,
                        key: Math.random()
                    }
                ]
            }
        })
    }

    setActivePanel(panel) {
        this.setState({
            activePanel: panel
        })
    }

    renderEditor() {
        const {data} = this.state;
        return (
            <div className="row">
                <div className="large-12 columns">
                    <ul className="tabs" id="shop-edit-tabs">
                        <li className="tabs-title is-active">
                            <a onClick={(e) => {e.preventDefault(); this.setActivePanel('panel-1')}}
                                aria-selected={this.state.activePanel === 'panel-1'}>
                                Opis produktu
                            </a>
                        </li>
                        <li className="tabs-title">
                            <a onClick={(e) => {e.preventDefault(); this.setActivePanel('panel-2')}}
                                aria-selected={this.state.activePanel === 'panel-2'}>
                                Galeria zdjęć
                            </a>
                        </li>
                    </ul>
                    <div className="tabs-content">
                        <div className={`tabs-panel ${this.state.activePanel === 'panel-1' ? 'is-active' : ''}`} id="panel-1">
                            <div className="row">
                                <div className="large-12 columns">
                                    <h5><small>Pamietaj o kliknięciu 'zapisz' po wprowadzeniu zmian</small></h5>
                                </div>
                            </div>
                            <div className="row">
                                <div className="large-6 columns">
                                    <div className="callout primary">
                                        <div className="row">
                                            <div className="large-12 columns">
                                                <label htmlFor="item_name">
                                                    Nazwa
                                                </label>
                                                <input type="text" id="item_name" value={data.name} onChange={e => this.onInputChange("name", e.target.value)} />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div className="large-6 columns">
                                    <div className="callout ">
                                        <h5>Stan <small>Szkic nie jest dostępny do publicznego wglądu</small></h5>
                                        <select value={data.state} onChange={e => this.onInputChange("state", e.target.value)}>
                                            <option value="draft">Szkic (nieopublikowane)</option>
                                            <option value="published">Opublikowane</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="large-12 columns">
                                    <div className="callout">
                                        Opis
                                        <ReactQuill theme="snow" value={data.description} onChange={(e) => this.onInputChange("description", e)} />
                                    </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="large-12 columns">
                                    <div className="callout ">
                                        <div className="row">
                                            <div className="columns large-12">
                                                <h5>Rodzaj <small>Wzory, rozmiary, etc</small></h5>
                                            </div>
                                        </div>
                                        <div className="row">
                                            <div className="large-7 columns">
                                                Nazwa
                                            </div>
                                            <div className="large-2 columns">
                                                Dostępna liczba sztuk
                                            </div>
                                            <div className="large-2 columns">
                                                Cena
                                            </div>
                                            <div className="large-1 columns">

                                            </div>
                                        </div>
                                        {data && data.item_kinds && data.item_kinds.filter(el => !el._destroy).map((el, idx) => {
                                            return (
                                                <div className="row" key={el.key}>
                                                    <div className="large-7 columns">
                                                        <input type="text" value={el.name} onChange={e => this.onItemKindsChange("name", el.key, e.target.value)}/>
                                                    </div>
                                                    <div className="large-2 columns">
                                                        <input type="number" value={el.quantity} onChange={e => this.onItemKindsChange("quantity", el.key, e.target.value)}/>
                                                    </div>
                                                    <div className="large-2 columns">
                                                        <input type="number" step="0.01" value={el.price} onChange={e => this.onItemKindsChange("price", el.key, e.target.value)}/>
                                                    </div>
                                                    <div className="large-1 columns">
                                                        <button className="button alert" onClick={() => this.onItemKindsChange("_destroy", el.key, true)}>Usuń</button>
                                                    </div>
                                                </div>
                                            )
                                        })}
                                        <div className="button succes" onClick={() => this.addItemAttributes()}>Dodaj</div>
                                    </div>
                                </div>
                            </div>
                            <div className="row">
                                <div className="large-6 columns text-right">
                                    <div className="button expanded info" onClick={this.saveChanges.bind(this)}>
                                        Zapisz zmiany
                                    </div>
                                </div>
                                <div className="large-6 columns">
                                    <Link to="/" className="button  expanded secondary hollow">
                                        Powrót
                                    </Link>
                                </div>
                            </div>
                        </div>
                        <div className={`tabs-panel ${this.state.activePanel === 'panel-2'  ? 'is-active' : ''}`} id="panel-2">
                            <div className="row">
                                <div className="large-12 columns">
                                    <FileUploader userId={this.context} uploadableId={this.state.data && this.state.data.id} uploadableType={"Shop::ItemRecord"} files={this.state.data && this.state.data.photos} />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        )
    }

    render() {
        const {isLoading} = this.state;
        return <>
            <ToastContainer></ToastContainer>
            {isLoading && <div className="row">
                <div className="large-12 columns">
                    <Spinner></Spinner>
                </div>
            </div>}
            {!isLoading && this.renderEditor()}
        </>
    }
}

export default withRouter(ShopItemContainer);
